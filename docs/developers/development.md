# Desarrollo

## Instalar un nuevo requerimiento en la imagen base

Si necesitamos instalar y configurar un nuevo requerimiento para andino, lo recomendable es instalarlo
en la imagen de datosgobar/portal-base. Esto permitira mantener el build de datosgobar/portal-andino
mas pequeño y rapido.

Para ejemplificar esto, supondremos que queremos levantar los workers de RQ usando supervisor.
Esta implementación, presente en [ckan 2.7](http://docs.ckan.org/en/2.7/maintaining/background-tasks.html#background-job-queues),
require levantar [supervisor](http://supervisord.org/) con una [configuración especial](https://github.com/ckan/ckan/blob/2.7/ckan/config/supervisor-ckan-worker.conf) para levantar los workers.

### Instalar nuevo requerimiento

Para instalar `supervisor` en el portal base, podemos hacer uso de la tarea de `ansible` encargada de instalar los
requerimientos para la aplicación. A la fecha, este código se encuentra en [`dependencies.yml`](https://github.com/datosgobar/portal-base/blob/c2dfe6613af1b56ae07e6e1303245f6c206a7066/base_portal/roles/portal/tasks/dependencies.yml#L18)

La parte que instala los requerimientos quedaria:

```yaml

- name: Install dependencies
  apt:
    name: "{{ item }}"
    state: present
  with_items:
    - libevent-dev
    # Otras dependencias
    - gettext
    - supervisor

```

Al agregar `supervisor`, este sera instalado cuando la generacion de la imagen termine.
Ahora solo lo siguiente seria agregar la configuracion para levantar las colas de rq, con la configuracion que trae ckan.

### Configuracion

El mejor punto para agrgar esta configuracion es en el archivo [`configure.yml`](https://github.com/datosgobar/portal-base/blob/c2dfe6613af1b56ae07e6e1303245f6c206a7066/base_portal/roles/portal/tasks/configure.yml).
El mismo es utilizado _despues_ de que ckan es instalado, por lo que el archivo de configuracion ya esta presente en el sistema.

Para eso agregaremos una tarea mas de ansible, usaremos el modulo [`copy`](https://docs.ansible.com/ansible/2.4/copy_module.html).
Al final de `configure.yml` agregamos algo como:

```yaml

# Otras tareas

- name: Copy supervisor configuration
  copy:
    src: /usr/lib/ckan/default/src/ckan/ckan/config/supervisor-ckan-worker.conf
    dest: /etc/supervisor/conf.d/
    remote_src: yes

```

### Configuracion propia

Algo que podriamos desear es tener nuestra propia configuracion de supervisor, que se basa en la que nos
provee ckan. Para esto copiamos el archivo `supervisor-ckan-worker.conf` desde dentro del contenedor y
lo colocamos al lado de `production.ini.j2`, dentro del directorio `templates/ckan`.
Luego cambiamos la tarea de ansible para que copie nuestro archivo:

```yaml

# Otras tareas

- name: Copy supervisor configuration
  copy:
    src: ckan/supervisor-ckan-worker.conf
    dest: /etc/supervisor/conf.d/

```

### Inicio automatico

Para lograr que supervisor se inicie automatiamente cada vez que se levante el portal,
debemos correr `service supervisor restart` mientras esta se levanta, en "runtime". El mejor lugar para esto
es el script que se corre por defecto: `start_ckan.sh.j2`.

En este script, agregamos los comandos que queremos *antes* de que la aplicacion sea iniciada:

```
# otros comandos ...

echo "Iniciando Supervisor"
service supervisor restart

service apache2 stop
exec {{ CKAN_INIT }}/run_andino.sh
```


Como este archivo

### Generacion del nuevo contenedor

Ahora, para probar estos cambios, generamos una nueva imagen de `datosgobar/portal-base`:

```
base_image="datosgobar/portal-base:test"

cd portal-base/;

docker build base_portal -t "$base_image";

```

Esto generara una imagen con el tag (o nombre) "datosgobar/portal-base:test".

Para hacer una prueba rapida, podemos correr:

`docker run --rm -it datosgobar/portal-base:test supervisord -n`

Este comando iniciara un contenedor con supervisor corriendo. Deberiamos ver en consola los
siguiente mensajes (podemos salir del contenedor usando `Ctrl+c`):

```
2018-06-22 18:55:46,593 CRIT Supervisor running as root (no user in config file)
2018-06-22 18:55:46,593 WARN Included extra file "/etc/supervisor/conf.d/supervisor-ckan-worker.conf" during parsing
2018-06-22 18:55:46,615 INFO RPC interface 'supervisor' initialized
```

Para probar esto directamente en el contenedor de `portl-andino`, debemos
**generar una nueva imagen del contenedor en base a la imagen del portal base**.
Para esto, en el archivo `Dockerfile` del portal, cambiamor el `FROM`, utilizando la
imagen temporal que acabamos de crear:

```
FROM datosgobar/portal-base:test

# ... otros comandos
```

Ahora generamos la nueva imagen:

```
cd portal-andino/

docker build -t portal-andino:test .
```


Luego iniciamos la aplicacion en modo desarrollo:

```
cd portal-andino/

./dev.sh setup;
```


Una vez iniciada la aplicacion, entramos al contenedor y verificamos que supervisor este corriendo:

```
cd portal-andino/
./dev.sh console

# Una vez en el contenedor
supervisorctl
```

En este momento deberiamos ver el estdo de supervisor. Para salir, usamos  `Ctrl + C`.

Si comprovamos que el nuevo requerimiento esta instalado y configurado, volvemos el `Dockerfile`
a su estado anterior (deshaciendo el cambio en el `FROM`).
Luego debemos sacar una nueva imagen del **portal-base** y finalmente una nueva de **portal-andino**
que se base en la anterior.

