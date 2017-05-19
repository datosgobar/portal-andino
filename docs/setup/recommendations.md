# Recomendaciones

Mantener segura un servidor web puede ser una tarea ardua, pero sobre todo es _constante_, ya que _constantemente_ se detectan nuevas vulnerabilidades en los distintos softwares.
Y un servidor web no es la excepcion!
En este (muy) breve documento, se darán pequeñas recomendaciones para mantener seguro el servidor, no solo antes posibles atacantes, sino tambien ante posibles fallos del sistema y como efectuar mitigaciones.

Las siguientes recomendaciones puden ser implementadas fácilmente en un sistema Ubuntu 16.04, el cual es el recomendado (a la fecha), para correr la aplicación.


## HTTPS!

HTTPS permite que la coneccion entre el _browser_ y el servidor sea encriptada y de esta manera segura.
Es altamente recomendable usar HTTPS, para mantener la privacidad de los usuarios.
Google provee buena informacion sobre esto: https://developers.google.com/web/fundamentals/security/encrypt-in-transit/why-https


## Sistema y librerías

Es _altamente recomendable_ mantener el sistema operativo y las aplicaciones que usemos actualizadas. Constantemente se estan subiendo _fixes_ de seguridad y posibles intrusos podrían aprovechar que las aplicaciones o el mismo sistema operativo esten desactualizados.
Periodicamente podríamos constatar las nuevas versiones de nuestro software y actualizar dentro de lo posible. Como ejemplo, podemos ver que para Ubuntu 16.04 salió Ubuntu 16.04.2, con algunas correcciones de seguridad. [Ver](https://wiki.ubuntu.com/XenialXerus/ReleaseNotes/ChangeSummary/16.04.2).

## Firewall

**Todo servidor debe tener activado el firewall.** El firewall permitirá denegar (o permitr) el acceso a la red. En un servidor web, el puerto abierto al público deberían ser sólo el 80 (http) y el 443 (https). Además de ese puerto, si la máquina es accedida remotamente mediante un servidor SSH, deberíamos abrir este puerto también, pero con un límite de acceso.
La solución es facilmente implementable con el programa [`ufw`](https://help.ubuntu.com/community/UFW).


## SSH

Los servidores ssh permiten el acceso al servidor remotamente. **No debe permitirse el acceso por ssh mediante usuario y password**. Sólo debe permitirse el acceso mediante clave publica.
DigitalOcean tiene una buena guía de cómo configurar las claves pública [Ver](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2).


## Backups

Es altamente recomendable hacer copias de seguridad de los datos de la aplicacion, tanto la base de datos como los archivos de configuración y subidos por los usuarios.
Un ejemplo fácil de hacer un backup de la base de datos sería:

    container=$(docker-compose -f latest.yml ps -q db)
    backupdir=$(mktemp -d)
    today=`date +%Y-%m-%d.%H:%M:%S`

    backupfile="$backupdir/backup.gz"

    docker exec $container pg_dumpall -c -U postgres | gzip > "$backupfile"
    cp "$backupfile" .

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


### Logs

Por default docker escribe a un archivo con formato `json`, lo cual puede llevar a que se acumulen los logs de la aplicacion y estos archivos crezcan indefinidamente.
Para evitar esto, se puede configurar el [`logging driver`](https://docs.docker.com/engine/admin/logging/overview/) de docker.
La recomendacion es usar `journald` y configurarlo para que los logs sean persistentes. 