# HandBook

---

- [Instalacion de `Andino`](#instalacion-de-andino)
- [Desinstalar `Andino`](#desinstalar-andino)
- [Que esta corriendo docker?](#que-esta-corriendo-docker)
- [Ingresar al contendor pricipal de andino](#ingresar-al-contendor-pricipal-de-andino)
- [Listar todas las `Propiedades` de cada contenedor](#listar-todas-las-propiedades-de-cada-contenedor)
- [Usuarios](#usuarios)
  - [`Crear` un usuario `ADMIN` dentro de `Andino`](#crear-un-usuario-admin-dentro-de-andino)
  - [Listar mis usuarios dentro de `Andino`](#listar-mis-usuarios-dentro-de-andino)
  - [Ver los datos de un usuario dentro de `Andino`](#ver-los-datos-de-un-usuario-dentro-de-andino)
  - [Crear un nuevo usuario de `Andino`](#crear-un-nuevo-usuario-de-andino)
  - [Crear un nuevo usuario\(EXTENDIDO\) de `Andino`](#crear-un-nuevo-usuarioextendido-de-andino)
  - [Eliminar un usuario de `Andino`](#eliminar-un-usuario-de-andino)
  - [Cambiar password de un usuario de `Andino`](#cambiar-password-de-un-usuario-de-andino)
- [Acceso a la data de Andino](#acceso-a-la-data-de-andino)
  - [Encontrar los `volumenes` de mi andino dentro de mi `FS`](#encontrar-los-volumenes-de-mi-andino-dentro-de-mi-fs)
  - [Ver los `IPs` de mis contenedores](#ver-los-ips-de-mis-contenedores)
  - [Ver las `variables de entorno` de tienen mis contenedores](#ver-las-variables-de-entorno-que-tienen-mis-contenedores)
  - [Acceder con `psql` a las `DB de andino`](#acceder-con-psql-a-las-db-de-andino)
- [Backups](#backups)
  - [Hacer `backup` de las `DBs de Andino`](#hacer-backup-de-las-dbs-de-andino)
  - [Realizar un `backup` del fs de `Andino`](#realizar-un-backup-del-file-system-de-andino)
- [Actualizaciones](#actualizaciones)
  - [Como `actualizo` mi `Andino`?](#como-actualizo-mi-andino)
- [Logs](#logs)
  - [Eliminar `logs` antiguos de `Docker`](#eliminar-logs-antiguos-de-docker)
  - [Eliminar logs dentro de Andino](#eliminar-logs-dentro-de-andino)
- [Eliminar objetos definitamente](#eliminar-objetos-definitamente)
  - [Purgar Organizaciones Borradas](#purgar-organizaciones-borradas)
  - [Purgar Grupos Borrados](#purgar-grupos-borrados)
  - [Purgar Datasets Borrados](#purgar-datasets-borrados)
  - [Listar nombres de los datasets contenidos en Andino](#listar-nombres-de-los-datasets-contenidos-en-andino)

<!-- /MarkdownTOC -->


## Instalación de `Andino`:

- De esta manera, vamos a lograr tener toda la plataforma corriendo y con autoinicio luego de un reboot o shutdown de la VM contenedora.
La recomendación es instalarla en un directorio protegido (`/etc/portal/` por default).

Para ver los pasos de instalación, dirigirse a [Guía de instalación](setup/install.md) y seguir la instalación simplificada.

Luego de la instalación, el comando `andino-ctl` debería estar disponible.
Este comando usaremos para manejar la aplicación, aunque siempre podemos usar `docker` y `docker-compose`.

*NOTA:* Muchos de estos comandos podrian usar `sudo` ya que pueden necesitarse permisos de `root` para correr comandos en docker.

## Desinstalar `Andino`:

Esta secuencia de comandos va a ELIMINAR TODOS LOS CONTENEDORES, IMAGENES y VOLUMENES de la aplicación de la vm donde esta instalada la plataforma.

```bash
sudo andino-ctl explode
```

## Que esta corriendo docker?

Para obtener una lista de lo que esta corriendo actualmente en la aplicación con Docker, podemos usar el siguiente comando:

    andino-ctl ps # Tabla de ejecucion actual
    andino-ctl ps -q # Listado de IDs de cada contenedor
    andino-ctl ps -aq # Listado de IDs de todos los contenedores disponibles.


## Ingresar al contendor pricipal de andino

    andino-ctl exec /bin/bash


## Listar todas las `Propiedades` de cada contenedor

    andino-ctl ps -q portal solr db | xargs -n 1 | while read container; do docker inspect $container; done

## Usuarios

### `Crear` un usuario `ADMIN` dentro de `Andino`

    andino-ctl add_admin mi_nuevo_usuario_admin


### Listar mis usuarios dentro de `Andino`

    andino-ctl list_users

### Ver los datos de un usuario dentro de `Andino`

    andino-ctl view_user nombre-de-usuario


### Crear un nuevo usuario de `Andino`

    andino-ctl add_user nombre-de-usuario


### Crear un nuevo usuario(EXTENDIDO) de `Andino`

    andino-ctl add_user nombre-de-usuario [email=mi-usuario@host.com password=mi-contraseña-rara apikey=unsecretomisticonoleible]


### Eliminar un usuario de `Andino`

    andino-ctl delete_user nombre-de-usuario


### Cambiar password de un usuario de `Andino`

    andino-ctl chpass nombre-de-usuario

## Acceso a la data de Andino

### Encontrar los `volumenes` de mi andino dentro de mi `FS`

    andino-ctl find_volumes


### Ver los `IPs` de mis contenedores

    andino-ctl show_ips

### Ver las `variables de entorno` que tienen mis contenedores

    andino-ctl show_envs

### Acceder con `psql` a las `DB de andino`

    andino-ctl exec_db
    # psql \c ckan db default CKAN
    # psql \c datastore_default db datastore CKAN

## Backups

### Hacer `backup` de las `DBs de Andino`

Creará un backup de la base de datos en /etc/andino/backups/database

    andino-ctl backup_db
    ls /etc/andino/backups/database

#### Opcional

Idea!

Luego de haber realizado los backups podriamos utilizar `scp` o algun gestor parecido para enviar nuestros backups a algún tipo de storage.

```
scp /etc/portal/backups/database/andino-backup-*.gz mi-usuario:pass@mi-host-de-almacenamiento:xxx/ruta/al/directorio/de/bkps

# No olidemos eliminar todos los archivos generados:

rm -f /etc/portal/backups/database/andino-backup-*.gz

```

### Realizar un `backup` del file system de `Andino`

```bash
andino-ctl backup_fs
ls /etc/andino/backups/files
```

### Realizar un `backup` de la configuración de `Andino`

```bash
andino-ctl backup_conf
ls /etc/andino/backups/files
```

## Actualizaciones


### Como `actualizo` mi `Andino`?

Las actualizaciones se llevan a cabo mediante un script de update. El mismo se puede encontrar acá: [update.py](https://github.com/datosgobar/portal-base/blob/master/deploy/update.py)

    app_dir=/etc/portal
    cd $app_dir
    sudo wget https://raw.github.com/datosgobar/portal-base/master/deploy/update.py
    sudo python ./update.py

## Logs

### Eliminar `logs` antiguos de `Docker`

Dentro del nomal funcionamiento de la plataforma, se generan gran catidad de logs, los cuales, ante un incidencia, son sumamente utiles, pero luego de un tiempo, y sabiendo que los mismo se almacenan internamente en Andino, podria ser necesario eliminarlos.

    sudo su -c "ls  /var/lib/docker/containers/ | xargs -n1 | while read docker_id; do truncate -s 0 /var/lib/docker/containers/${docker_id%/*}/${docker_id%/*}-json.log; done"

### Configurar otro `logging driver`

Otra alternativa es configuar otro `logging driver` de docker para que use `journal`. De este modo el systema operativo se ocupará de los logs. Para esto es necesario que `journald` esté instalado en el sistema.

### Eliminar logs dentro de Andino

    docker-compose -f /etc/portal/latest.yml exec portal truncate -s 0 /var/log/apache2/*.log


## Eliminar objetos definitivamente

Es bien sabido que dentro de `CKAN` cada vez que borranmos algun elemento, en verdad no se borra, sino que pasa a estar `ìnactivo`, por tanto, tener alguna forma de eliminar elementos de manera definitiva, resulta altamente necesario.

## Purgar Organizaciones Borradas

    curl -X POST http://tu-host/api/3/action/organization_purge -H "Authorization:tu-api-key" -F id=id-o-nombre-que-se-desea-borrar

## Purgar Grupos Borrados

    curl -X POST http://tu-host/api/3/action/group_purge -H "Authorization:tu-api-key" -F id=id-o-nombre-que-se-desea-borrar

## Purgar Datasets Borrados

    curl -X POST http://tu-host/api/3/action/dataset_purge -H "Authorization:tu-api-key" -F id=id-o-nombre-que-se-desea-borrar


## Listar nombres de los datasets contenidos en Andino

```bash
docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh  --plugin=ckan dataset list | grep -v DEBUG | grep -v count  | grep -v Datasets | xargs -n2 | while read id name; do echo $name; done

# Idea!
# ====
# Si por alguna razon, por ejemplo, quisiera eliminar todos los datasets contenidos dentro de la plataforma
# podría armar una función del estilo:

DATASETS=$(docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh  --plugin=ckan dataset list | grep -v DEBUG | grep -v count  | grep -v Datasets)
echo $DATASETS | xargs -n2 | while read id name; do docker exec andino /etc/ckan_init.d/paster.sh --plugin=ckan dataset purge $name; done
```
