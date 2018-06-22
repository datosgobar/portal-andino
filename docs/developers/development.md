# Desarrollo

## Instalar un nuevo requerimiento en la imagen base

Si necesitamos instalar y configurar un nuevo requerimiento para andino, lo recomendable es instalarlo
en la imagen de datosgobar/portal-base. Esto permitira mantener el build de datosgobar/portal-andino
mas pequeño.

Para ejemplificar esto, supondremos que queremos levantar los workers de RQ usando supervisor.
Esta implementación, presente en [ckan 2.7](http://docs.ckan.org/en/2.7/maintaining/background-tasks.html#background-job-queues),
require levantar [supervisor](http://supervisord.org/) con una [configuración especial](https://github.com/ckan/ckan/blob/2.7/ckan/config/supervisor-ckan-worker.conf) para levantar los workers.

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

Ahora, para probar estos cambios, generamos una nueva imagen de `datosgobar/portal-base`:

```
local_image="datosgobar/portal-base:test"

cd portal-base/;

docker build base_portal -t "$local_image";

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


