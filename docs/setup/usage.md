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


## Instalacion de `Andino`:

- De esta manera, vamos a lograr tener toda la plataforma corriendo y con autoinicio luego de un reboot o shutdown de la VM contenedora. La recomendación es instalarla en un directorio protegido (`/etc/portal/` por ejemplo). 

```bash

app_dir="/etc/portal/"
sudo mkdir $app_dir
cd $app_dir

# Descarga el script de instalación
wget https://raw.github.com/datosgobar/portal-base/master/deploy/install.py

# El script requiere ciertas credenciales que serán unicas de cada instalación
# Reemplazar $EMAIL, $HOST, $DB_USER, $DB_PASS, $STORE_USER, $STORE_PASS con las correspondientes.
python ./install.py --error_email $EMAIL --site_host=$HOST \
    --database_user=$DB_USER --database_password=$DB_PASS \
    --datastore_user=$STORE_USER --datastore_password=$STORE_PASS
```

## Desinstalar `Andino`:

Esta secuencia de comandos va a ELIMINAR TODOS LOS CONTENEDORES, IMAGENES y VOLUMENES de la aplicación de la vm donde esta instalada la plataforma.

```bash
app_dir="/etc/portal/"
cd $app_dir
docker-compose -f latest.yml down -v
cd ~/
sudo rm /etc/portal -r
```

## Que esta corriendo docker?

Para obtener una lista de lo que esta corriendo actualmente Docker, podemos usar el siguiente comando:

    docker ps # Tabla de ejecucion actual
    docker ps -q # Listado de IDs de cada contenedor
    docker ps -aq # Listado de IDs de todos los contenedores disponibles.


## Ingresar al contendor pricipal de andino

    docker-compose -f /etc/portal/latest.yml exec portal /bin/bash


## Listar todas las `Propiedades` de cada contenedor

    docker-compose -f /etc/portal/latest.yml ps -q portal solr db | xargs -n 1 | while read container; do docker inspect $container; done

## Usuarios

### `Crear` un usuario `ADMIN` dentro de `Andino`

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/add_admin.sh mi_nuevo_usuario_admin


### Listar mis usuarios dentro de `Andino`

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user list

### Ver los datos de un usuario dentro de `Andino`

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user nombre-de-usuario


### Crear un nuevo usuario de `Andino`

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user add nombre-de-usuario


### Crear un nuevo usuario(EXTENDIDO) de `Andino`

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user add nomber [email=mi-usuario@host.com password=mi-contraseña-rara apikey=unsecretomisticonoleible]


### Eliminar un usuario de `Andino`

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user remove nombre-de-usuario


### Cambiar password de un usuario de `Andino`

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user setpass nombre-de-usuario

## Acceso a la data de Andino

### Encontrar los `volumenes` de mi andino dentro de mi `FS`

    docker-compose -f /etc/portal/latest.yml ps -q andino solr db | xargs -n 1 | while read container; do docker inspect -f ' {{.Name}}: {{range .Mounts}}{{.Source}}: {{.Destination}}  {{end}} ' $container; done


### Ver los `IPs` de mis contenedores

    docker-compose -f /etc/portal/latest.yml ps -q andino solr db | xargs -n 1 | while read container; do docker inspect -f '{{.Name}}: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container; done

### Ver las `variables de entorno` que tienen mis contenedores

    docker-compose -f /etc/portal/latest.yml ps -q andino solr db | xargs -n 1 | while read container; do docker inspect -f '{{range $index, $value := .Config.Env}}export {{$value}}{{println}}{{end}}' $container; done

### Acceder con `psql` a las `DB de andino`

    docker-compose -f dev.yml exec db psql -U postgres
    # psql \c ckan db default CKAN
    # psql \c datastore_default db datastore CKAN

## Backups

### Hacer `backup` de las `DBs de Andino`


```bash
# Algunas variables que usaremos
today=`date +%Y-%m-%d.%H:%M:%S`
filename="backup-$today.gz"
container="andino-db"

# Creo un directorio temporal y defino dónde generaré el backup
backupdir=$(mktemp -d)
backupfile="$backupdir/$filename"

# Exporto la base de datos
docker exec $container pg_dumpall -c -U postgres | gzip > "$backupfile"

# Copio el archivo al directorio actual y borro el original
# Podría reemplazar $PWD con mi directorio de backups, como /etc/portal/backups
mv "$backupfile" $PWD

# Opcional

# Idea!
# ====
# luego de haber realizado los backups podriamos utilizar `scp` o algun gestor parecido para enviar nuestros backups a algún tipo de storage.

# scp /etc/portal/backups/backup-*.gz mi-usuario:pass@mi-host-de-almacenamiento:xxx/ruta/al/directorio/de/bkps

# No olidemos eliminar todos los archivos generados:
#
# rm -f /etc/portal/backups/backup-*.gz

```

### Realizar un `backup` del file system de `Andino`

```bash
# Exporto el path al almacenamiento del volumen
export CKAN_FS_STORAGE=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/lib/ckan" }}{{ .Source }}{{ end }}{{ end }}' andino)

# Creo un tar.gz con la info.
tar -C "$(dirname "$CKAN_FS_STORAGE")" -zcvf /ruta/para/guardar/mis/bkps/mi_andino.fs-data_$(date +%F).tar.gz "$(basename "$CKAN_FS_STORAGE")"
```

### Realizar un `backup` de la configuración de `Andino`

```bash
# Exporto el path al almacenamiento del volumen
export ANDINO_CONFIG=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/etc/ckan/default" }}{{ .Source }}{{ end }}{{ end }}' andino)

# Creo un tar.gz con la info.
tar -C "$(dirname "$ANDINO_CONFIG")" -zcvf /ruta/para/guardar/mis/bkps/mi_andino.config-data_$(date +%F).tar.gz "$(basename "$ANDINO_CONFIG")"
```

## Actualizaciones


### Como `actualizo` mi `Andino`?

En la [documentación de actualización](update.md) encontrarás esto detallado

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
