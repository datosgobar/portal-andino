<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Mantenimiento](#mantenimiento)
    - [Exploración de la instancia de andino](#exploracion-de-la-instancia-de-andino)
        - [¿Qué está corriendo docker?](#que-esta-corriendo-docker)
        - [Ingresar al contendor pricipal de andino](#ingresar-al-contendor-pricipal-de-andino)
        - [Listar todas las `Propiedades` de cada contenedor](#listar-todas-las-propiedades-de-cada-contenedor)
    - [Administración de usuarios](#administracion-de-usuarios)
        - [Crear un usuario ADMIN](#crear-un-usuario-admin)
        - [Listar mis usuarios](#listar-mis-usuarios)
        - [Ver los datos de un usuario](#ver-los-datos-de-un-usuario)
        - [Crear un nuevo usuario](#crear-un-nuevo-usuario)
        - [Crear un nuevo usuario extendido](#crear-un-nuevo-usuario-extendido)
        - [Eliminar un usuario](#eliminar-un-usuario)
        - [Cambiar password de un usuario](#cambiar-password-de-un-usuario)
    - [Configuraciones de andino](#configuraciones-de-andino)
        - [Cambiar la configuración del SMTP](#cambiar-la-configuracion-del-smtp)
        - [Cambiar el remitente de los correos electrónicos que envía Andino](#cambiar-el-remitente-de-los-correos-electronicos-que-envia-andino)
        - [Deshabilitar la URL `/catalog.xlsx`](#deshabilitar-la-url--catalogxlsx)
    - [Acceso a los datos de andino](#acceso-a-los-datos-de-andino)
        - [Encontrar los volúmenes de mi andino dentro del filesystem del host](#encontrar-los-volumenes-de-mi-andino-dentro-del-filesystem-del-host)
        - [Ver las direcciones IP de mis contenedores](#ver-las-direcciones-ip-de-mis-contenedores)
        - [Ver las variables de entorno que tienen mis contenedores](#ver-las-variables-de-entorno-que-tienen-mis-contenedores)
        - [Acceder con un cliente de PostgreSQL a las bases de datos](#acceder-con-un-cliente-de-postgresql-a-las-bases-de-datos)
    - [Eliminar objetos definitivamente](#eliminar-objetos-definitivamente)
        - [Purgar Organizaciones Borradas](#purgar-organizaciones-borradas)
        - [Purgar Grupos Borrados](#purgar-grupos-borrados)
        - [Purgar Datasets Borrados](#purgar-datasets-borrados)
        - [Listar nombres de los datasets contenidos en Andino](#listar-nombres-de-los-datasets-contenidos-en-andino)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Mantenimiento

## Exploración de la instancia de andino

### ¿Qué está corriendo docker?

Para obtener una lista de lo que está corriendo actualmente Docker, podemos usar el siguiente comando:

    docker ps # Tabla de ejecucion actual
    docker ps -q # Listado de IDs de cada contenedor
    docker ps -aq # Listado de IDs de todos los contenedores disponibles.


### Ingresar al contendor pricipal de andino

El contenedor principal de andino, donde se ejecuta la aplicación CKAN, es denominado `portal`. Para ingresar en una sesión de consola en el contenedor, ejecutar:

    docker-compose -f /etc/portal/latest.yml exec portal /bin/bash


### Listar todas las `Propiedades` de cada contenedor

    docker-compose -f /etc/portal/latest.yml ps -q portal solr db | xargs -n 1 | while read container; do docker inspect $container; done


## Administración de usuarios

### Crear un usuario ADMIN

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/add_admin.sh mi_nuevo_usuario_admin


### Listar mis usuarios

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user list

### Ver los datos de un usuario

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user nombre-de-usuario


### Crear un nuevo usuario

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user add nombre-de-usuario


### Crear un nuevo usuario extendido

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user add nomber [email=mi-usuario@host.com password=mi-contraseña-rara apikey=unsecretomisticonoleible]


### Eliminar un usuario

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user remove nombre-de-usuario


### Cambiar password de un usuario

    docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user setpass nombre-de-usuario

## Configuraciones de andino

### Cambiar la configuración del SMTP

Por defecto, andino usará un servidor postfix integrado para el envío de emails.
Para usar un servidor SMTP propio, debemos cambiar la configuración del archivo `production.ini`.
Para lograrlo, podemos hacerlo de dos formas:

1 ) Ingresando al contenedor.

Debemos buscar y editar en el archivo `production.ini` la configuración
de email que luce como:

```
## Email settings

error_email_from=admin@example.com
smtp.server = postfix
#smtp.starttls = False
smtp.user = portal
smtp.password = portal
smtp.mail_from = administrador
```

Para editarlo directamente, ejecutamos los comandos:

```bash
# Ingresar al contenedor

cd /etc/portal
docker-compose -f latest.yml exec portal /bin/bash

# Una vez adentro, editamos el archivo production.ini
# Debemos buscar la configuración debajo del comentario "## Email settings"
 
vim /etc/ckan/default/production.ini

# Editamos y luego de salir del contenedor lo reiniciamos

docker-compose -f latest.yml restart portal nginx
```    

2 ) Ejecutando comandos paster

Suponiendo que nuestro servidor SMTP esta en smtp.gmail.com, la dirección de correo del usuario es `smtp_user_mail@gmail.com`, 
la contraseña de esa dirección de correo `mi_pass` y queremos usar "tls", podemos ejecutar los siguientes comandos:

```
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "smtp.server=smtp.gmail.com:587";
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "smtp.user=smtp_user_mail@gmail.com";
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "smtp.password=mi_pass";
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "smtp.starttls=True";
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "smtp.mail_from=smtp_user_mail@gmail.com";

# Finalmente reiniciamos el contenedor
docker-compose -f latest.yml restart portal nginx
```

Tener en cuenta que si se utiliza un servidor SMTP, se debe setear la configuración con **un correo electrónico 
de @gmail.com**, y que **starttls debe estar en True**.

### Cambiar el remitente de los correos electrónicos que envía Andino

Para modificar el remitente de los correos electrónicos que el sistema envía (por ejemplo los de creación de usuarios nuevos o los de olvido de contraseña) se deben seguir los pasos de la sección [Cambiar la configuración del SMTP](#cambiar-la-configuracion-del-smtp) pero modificando el atributo de configuración `smtp.mail_from`.

### Deshabilitar la URL `/catalog.xlsx`

En caso de desear deshabilitar la URL `/catalog.xlsx` puede ejecutar el siguiente comando:

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "andino.disable_catalog_xlsx_url=True";

En caso de querer restaurarlo, debe configurar el atributo `andino.disable_catalog_xlsx_url` al valor `False`.

## Acceso a los datos de andino

### Encontrar los volúmenes de mi andino dentro del filesystem del host

    docker-compose -f /etc/portal/latest.yml ps -q andino solr db | xargs -n 1 | while read container; do docker inspect -f ' {{.Name}}: {{range .Mounts}}{{.Source}}: {{.Destination}}  {{end}} ' $container; done


### Ver las direcciones IP de mis contenedores

    docker-compose -f /etc/portal/latest.yml ps -q andino solr db | xargs -n 1 | while read container; do docker inspect -f '{{.Name}}: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container; done

### Ver las variables de entorno que tienen mis contenedores

    docker-compose -f /etc/portal/latest.yml ps -q andino solr db | xargs -n 1 | while read container; do docker inspect -f '{{range $index, $value := .Config.Env}}export {{$value}}{{println}}{{end}}' $container; done

### Acceder con un cliente de PostgreSQL a las bases de datos

    docker-compose -f dev.yml exec db psql -U postgres
    # psql \c ckan db default CKAN
    # psql \c datastore_default db datastore CKAN

## Eliminar objetos definitivamente

Es bien sabido que dentro de CKAN cada vez que borranmos algun elemento, en verdad no se borra, sino que pasa a estar inactivo, por tanto, tener alguna forma de eliminar elementos de manera definitiva, resulta altamente necesario.

### Purgar Organizaciones Borradas

    curl -X POST http://tu-host/api/3/action/organization_purge -H "Authorization:tu-api-key" -F id=id-o-nombre-que-se-desea-borrar

### Purgar Grupos Borrados

    curl -X POST http://tu-host/api/3/action/group_purge -H "Authorization:tu-api-key" -F id=id-o-nombre-que-se-desea-borrar

### Purgar Datasets Borrados

    curl -X POST http://tu-host/api/3/action/dataset_purge -H "Authorization:tu-api-key" -F id=id-o-nombre-que-se-desea-borrar


### Listar nombres de los datasets contenidos en Andino

```bash
docker-compose -f /etc/portal/latest.yml exec portal /etc/ckan_init.d/paster.sh  --plugin=ckan dataset list | grep -v DEBUG | grep -v count  | grep -v Datasets | xargs -n2 | while read id name; do echo $name; done

## Backups

Es altamente recomendable hacer copias de seguridad de los datos de la aplicacion, tanto la base de datos como los archivos de configuración y subidos por los usuarios.

### Backup de la base de datos

Un ejemplo fácil de hacer un backup de la base de datos sería:

    container=$(docker-compose -f latest.yml ps -q db)
    today=`date +%Y-%m-%d.%H:%M:%S`
    filename="backup-$today.gz"

    # Creo un directorio temporal y defino dónde generaré el backup
    backupdir=$(mktemp -d)
    backupfile="$backupdir/$filename"

    # Exporto la base de datos
    docker exec $container pg_dumpall -c -U postgres | gzip > "$backupfile"

    # Copio el archivo al directorio actual y borro el original
    # Podría reemplazar $PWD con mi directorio de backups, como /etc/portal/backups
    mv "$backupfile" $PWD


Y para los demás archivos de la aplicación (requiere [`jq`](https://stedolan.github.io/jq/)):

    backupdir=$(mktemp -d)
    today=`date +%Y-%m-%d.%H:%M:%S`
    appbackupdir="$backupdir/application/"
    mkdir $appbackupdir
    container=$(docker-compose -f latest.yml ps -q portal)

    docker inspect --format '{{json .Mounts}}' $container  | jq -r '.[]|[.Name, .Source, .Destination] | @tsv' |
    while IFS=$'\t' read -r name source destination; do

        if ls $source/* 1> /dev/null 2>&1; then
            dest="$appbackupdir$name"
            mkdir -p $dest

            tar -C "$source" -zcvf "$dest/backup_$today.tar.gz" $(ls $source)
        else
            echo "No file at $source"
        fi
    done

    tar -C "$appbackupdir../" -zcvf backup.tar.gz "application/"

Podria colocarse esos scripts en el directorio donde se instaló la aplicación (ejemplo : `/etc/portal/backup.sh`) y luego agregar un `cron`:
Para correr el script cada domingo, podríamos usar la configuración `0 0 * * 0` (ver [cron](https://help.ubuntu.com/community/CronHowto) para más información)
Correr el comando `crontab -e` y agregar la línea:

    0 0 * * 0 cd /etc/portal/ && bash /etc/portal/backup.sh


### Realizar un backup del file system

    # Exporto el path al almacenamiento del volumen
    export CKAN_FS_STORAGE=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/lib/ckan" }}{{ .Source }}{{ end }}{{ end }}' andino)

    # Creo un tar.gz con la info.
    tar -C "$(dirname "$CKAN_FS_STORAGE")" -zcvf /ruta/para/guardar/mis/bkps/mi_andino.fs-data_$(date +%F).tar.gz "$(basename "$CKAN_FS_STORAGE")"


### Realizar un backup de la configuración


    # Exporto el path al almacenamiento del volumen
    export ANDINO_CONFIG=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/etc/ckan/default" }}{{ .Source }}{{ end }}{{ end }}' andino)

    # Creo un tar.gz con la info.
    tar -C "$(dirname "$ANDINO_CONFIG")" -zcvf /ruta/para/guardar/mis/bkps/mi_andino.config-data_$(date +%F).tar.gz "$(basename "$ANDINO_CONFIG")"

## Recomendaciones de Seguridad y Optimizaciones

Mantener seguro un servidor web puede ser una tarea ardua, pero sobre todo es _constante_, ya que _constantemente_ se detectan nuevas vulnerabilidades en los distintos softwares.
Y un servidor web no es la excepcion!
En este breve apartado, se darán pequeñas recomendaciones para mantener seguro el servidor, no solo antes posibles atacantes, sino tambien ante posibles fallos del sistema y como efectuar mitigaciones.

Las siguientes recomendaciones puden ser implementadas fácilmente en un sistema Ubuntu 16.04, el cual es el recomendado (a la fecha), para correr la aplicación.

### HTTPS

HTTPS permite que la coneccion entre el _browser_ y el servidor sea encriptada y de esta manera segura.
Es altamente recomendable usar HTTPS, para mantener la privacidad de los usuarios.
El portal de documentación para desarrolladores de Google provee buena informacion sobre esto:
https://developers.google.com/web/fundamentals/security/encrypt-in-transit/why-https


### Sistema y librerías

Es _altamente recomendable_ mantener el sistema operativo y las aplicaciones que usemos actualizadas. Constantemente se estan subiendo _fixes_ de seguridad y posibles intrusos podrían aprovechar que las aplicaciones o el mismo sistema operativo esten desactualizados.
Periodicamente podríamos constatar las nuevas versiones de nuestro software y actualizar dentro de lo posible. Como ejemplo, podemos ver que para Ubuntu 16.04 salió Ubuntu 16.04.2, con algunas correcciones de seguridad. [Ver](https://wiki.ubuntu.com/XenialXerus/ReleaseNotes/ChangeSummary/16.04.2).

### Firewall

**Todo servidor debe tener activado el firewall.** El firewall permitirá denegar (o permitr) el acceso a la red. En un servidor web, el puerto abierto al público deberían ser sólo el 80 (http) y el 443 (https). Además de ese puerto, si la máquina es accedida remotamente mediante un servidor SSH, deberíamos abrir este puerto también, pero con un límite de acceso.
La solución es facilmente implementable con el programa [`ufw`](https://help.ubuntu.com/community/UFW).


### SSH

Los servidores ssh permiten el acceso al servidor remotamente. **No debe permitirse el acceso por ssh mediante usuario y password**. Sólo debe permitirse el acceso mediante clave publica.
DigitalOcean tiene una buena guía de cómo configurar las claves pública [Ver](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2).

## Optimización de logging

### Configurar otro `logging driver`

Por default docker escribe a un archivo con formato `json`, lo cual puede llevar a que se acumulen los logs de la aplicacion y estos archivos crezcan indefinidamente.
Para evitar esto, se puede configurar el [`logging driver`](https://docs.docker.com/engine/admin/logging/overview/) de docker.
La recomendacion es usar `journald` y configurarlo para que los logs sean persistentes. 

### Eliminar `logs` antiguos de `Docker`

Dentro del nomal funcionamiento de la plataforma, se generan gran catidad de logs, los cuales, ante un incidencia, son sumamente utiles, pero luego de un tiempo, y sabiendo que los mismo se almacenan internamente en Andino, podria ser necesario eliminarlos.

    sudo su -c "ls  /var/lib/docker/containers/ | xargs -n1 | while read docker_id; do truncate -s 0 /var/lib/docker/containers/${docker_id%/*}/${docker_id%/*}-json.log; done"

### Eliminar logs dentro de Andino

    docker-compose -f /etc/portal/latest.yml exec portal truncate -s 0 /var/log/apache2/*.log
