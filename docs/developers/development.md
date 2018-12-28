<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Indice

- [Desarrollo](#desarrollo)
  - [Instalar un nuevo requerimiento en la imagen base](#instalar-un-nuevo-requerimiento-en-la-imagen-base)
    - [Instalar nuevo requerimiento](#instalar-nuevo-requerimiento)
    - [Configuración](#configuracion)
    - [Configuración propia](#configuracion-propia)
    - [Inicio automático](#inicio-automatico)
    - [Generación del nuevo contenedor](#generacion-del-nuevo-contenedor)
  - [Probar modificaciones y nuevas funcionalidades](#probar-modificaciones-y-nuevas-funcionalidades)
    - [Portal Andino](#portal-andino)
    - [Portal Andino Theme](#portal-andino-theme)
    - [Portal Base](#portal-base)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

- [Desarrollo](#desarrollo)
    - [Instalar un nuevo requerimiento en la imagen base](#instalar-un-nuevo-requerimiento-en-la-imagen-base)
        - [Instalar nuevo requerimiento](#instalar-nuevo-requerimiento)
        - [Configuración](#configuracion)
        - [Configuración propia](#configuracion-propia)
        - [Inicio automático](#inicio-automatico)
        - [Generación del nuevo contenedor](#generacion-del-nuevo-contenedor)
    - [Probar modificaciones y nuevas funcionalidades](#probar-modificaciones-y-nuevas-funcionalidades)
        - [Portal Andino](#portal-andino)
        - [Portal Andino Theme](#portal-andino-theme)
        - [Portal Base](#portal-base)

# Desarrollo

## Instalar un nuevo requerimiento en la imagen base

Si necesitamos instalar y configurar un nuevo requerimiento para andino, lo recomendable es instalarlo
en la imagen de datosgobar/portal-base. Esto permitirá mantener el build de datosgobar/portal-andino
más pequeño y rápido.

Para ejemplificar esto, supondremos que queremos levantar los workers de RQ usando supervisor.
Esta implementación, presente en [ckan 2.7](http://docs.ckan.org/en/2.7/maintaining/background-tasks.html#background-job-queues),
require levantar [supervisor](http://supervisord.org/) con una 
[configuración especial](https://github.com/ckan/ckan/blob/2.7/ckan/config/supervisor-ckan-worker.conf) para levantar los workers.

### Instalar nuevo requerimiento

Para instalar `supervisor` en el portal base, podemos hacer uso de la tarea de `ansible` encargada de instalar los
requerimientos para la aplicación. A la fecha, este código se encuentra en 
[`dependencies.yml`](https://github.com/datosgobar/portal-base/blob/c2dfe6613af1b56ae07e6e1303245f6c206a7066/base_portal/roles/portal/tasks/dependencies.yml#L18)

La parte que instala los requerimientos quedaría así:

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

Al agregar `supervisor`, éste será instalado cuando la generación de la imagen termine.
Ahora, lo siguiente sólo sería agregar la configuración para levantar las colas de rq, 
con la configuración que trae ckan.

### Configuración

El mejor punto para agregar esta configuración es en el archivo 
[`configure.yml`](https://github.com/datosgobar/portal-base/blob/c2dfe6613af1b56ae07e6e1303245f6c206a7066/base_portal/roles/portal/tasks/configure.yml).
El mismo es utilizado _después_ de que ckan es instalado, por lo que el archivo de configuración ya está 
presente en el sistema.

Para eso, añadiremos una tarea más de ansible, usaremos el módulo [`copy`](https://docs.ansible.com/ansible/2.4/copy_module.html).
Al final de `configure.yml`, agregaremos algo como:

```yaml

# Otras tareas

- name: Copy supervisor configuration
  copy:
    src: /usr/lib/ckan/default/src/ckan/ckan/config/supervisor-ckan-worker.conf
    dest: /etc/supervisor/conf.d/
    remote_src: yes

```

### Configuración propia

Algo que podríamos desear es tener nuestra propia configuración de supervisor, que se basa en la que nos
provee ckan. Para esto, copiamos el archivo `supervisor-ckan-worker.conf` desde dentro del contenedor y
lo colocamos al lado de `production.ini.j2`, dentro del directorio `templates/ckan`.
Luego, cambiamos la tarea de ansible para que copie nuestro archivo:

```yaml

# Otras tareas

- name: Copy supervisor configuration
  copy:
    src: ckan/supervisor-ckan-worker.conf
    dest: /etc/supervisor/conf.d/

```

### Inicio automático

Para lograr que supervisor se inicie automátiamente cada vez que se levante el portal,
debemos correr `service supervisor restart` mientras esta se levanta, en "runtime". El mejor lugar para esto
es el script que se corre por defecto: `start_ckan.sh.j2`.

En este script, agregamos los comandos que queremos *antes* de que la aplicación sea iniciada:

```
# otros comandos ...

echo "Iniciando Supervisor"
service supervisor restart

service apache2 stop
exec {{ CKAN_INIT }}/run_andino.sh
```

### Generación del nuevo contenedor

Ahora, para probar estos cambios, generamos una nueva imagen de `datosgobar/portal-base`:

```
base_image="datosgobar/portal-base:test"

cd portal-base/;

docker build base_portal -t "$base_image";

```

Esto generará una imagen con el tag (o nombre) "datosgobar/portal-base:test".

Para hacer una prueba rápida, podemos correr:

`docker run --rm -it datosgobar/portal-base:test supervisord -n`

Este comando iniciará un contenedor con supervisor corriendo. Deberíamos ver en consola los
siguiente mensajes (podemos salir del contenedor usando `Ctrl+c`):

```
2018-06-22 18:55:46,593 CRIT Supervisor running as root (no user in config file)
2018-06-22 18:55:46,593 WARN Included extra file "/etc/supervisor/conf.d/supervisor-ckan-worker.conf" during parsing
2018-06-22 18:55:46,615 INFO RPC interface 'supervisor' initialized
```

Para probar esto directamente en el contenedor de `portl-andino`, debemos
**generar una nueva imagen del contenedor en base a la imagen del portal base**.
Para esto, en el archivo `Dockerfile` del portal, cambiamos el `FROM`, utilizando la
imagen temporal que acabamos de crear:

```
FROM datosgobar/portal-base:test

# ... otros comandos
```

Ahora, generamos la nueva imagen:

```
cd portal-andino/

docker build -t portal-andino:test .
```


Luego, iniciamos la aplicación en modo desarrollo:

```
cd portal-andino/

./dev.sh setup;
```


Una vez iniciada la aplicación, entramos al contenedor y verificamos que supervisor esté corriendo:

```
cd portal-andino/
./dev.sh console

# Una vez en el contenedor
supervisorctl
```

En este momento, deberíamos ver el estado de supervisor. Para salir, usamos  `Ctrl + C`.

Si comprobamos que el nuevo requerimiento está instalado y configurado, volvemos el `Dockerfile`
a su estado anterior (deshaciendo el cambio en el `FROM`).
Luego, debemos sacar una nueva imagen del **portal-base** y, finalmente, una nueva de **portal-andino**
que se base en la anterior.


## Probar modificaciones y nuevas funcionalidades

### Portal Andino

Para levantar el contenedor, se debe ejecutar los siguientes comandos:
    
    ./dev.sh up
    ./dev.sh setup

Para acceder a la terminal del portal, ejecutar:

    ./dev.sh console
    
### Portal Andino Theme

Cuando el contenedor de Andino se levanta, se descarga y utiliza el branch master de portal-andino-theme.
Como queremos probar las modificaciones implementadas, es necesario reemplazar el código que existe en el contenedor.

Para esto, hay que asegurarnos de que exista el directorio `wrks` dentro del directorio de portal-andino en el host 
antes de levantar todo (en caso de no exista, ejecutar `mkdir wrks` dentro del directorio de portal-andino). 
Dentro de `wrks/`, debemos tener portal-andino-theme con los cambios realizados.

* Si ya existe en el host un directorio donde se encuentra el código de portal-andino-theme, la forma de traerlo a wrks 
es:

```
cp {directorio-de-portal-andino-theme} {directorio-de-portal-andino}/wrks/portal-andino-theme
```
    
* Si aún no existe (puede ocurrir, por ejemplo, para probar el código de un branch del repositorio), hay que clonarlo:

```
git clone -b {nombre-del-branch-con-los-cambios-a-testear} --single-branch https://github.com/datosgobar/portal-andino-theme.git
```

Ahora que ya tenemos portal-andino-theme listo, ejecutar los comandos para levantar el contenedor y acceder a la terminal.
Lo único que hace falta hacer para reemplazar el código de master es hacer un cp:

    cp -a /dev-app/wrks/portal-andino-theme/. /usr/lib/ckan/default/src/ckanext-gobar-theme/
    
Como último paso, reiniciar apache:

    apachectl restart

### Portal Base

Para poder probar el código de portal-base, hay que crear una nueva imagen, la cual será usada por el portal.

Dentro del directorio existente en el host de portal-base, hay que crearla mediante el siguiente comando y esperar 
a que termine:

    docker build base_portal -t "datosgobar/portal-base:{nombre-que-se-le-desea-dar-a-la-imagen}"

Como portal-andino tiene un nombre de imagen para portal-base dentro de su Dockerfile, será necesario reemplazarlo.
La primera línea de este archivo debería quedar con este contenido: 
`FROM datosgobar/portal-base:{nombre-que-se-le-dio-a-la-imagen-de-portal-base}`.

Ahora, al levantarse el portal se utilizará la imagen de portal-base generada con los nuevos cambios. 
