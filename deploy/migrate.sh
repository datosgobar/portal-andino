#!/usr/bin/env bash

set -e;

old_andino="app-ckan"
old_db="pg-ckan"
install_dir="/etc/portal"
database_backup="backup.gz"
app_backup="backup.tar.gz"

usage() {
    echo "Usage: `basename $0`" >&2
    echo "Se requiere las siguientes variables de entorno:" >&2
    echo "EMAIL, HOST, DB_USER, DB_PASS, STORE_USER, STORE_PASS" >&2
}

info() {
    echo "[INFO] $1";
}

if [ -z "$EMAIL" ] || [ -z "$HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$STORE_USER" ] || [ -z "$STORE_PASS" ]; then
    echo "Falta una variable de entorno."
    usage
    exit 1;
fi

function backup_database {
    info "Creando backup de la base de datos."
    container=$old_db
    backupdir=$(mktemp -d)
    backupfile="$backupdir/$database_backup"
    info "Iniciando backup de $container."
    info "Usando directorio temporal: $backupdir"
    docker exec $container pg_dumpall -c -U postgres | gzip > "$backupfile"
    info "Copiando backup a $PWD"
    cp "$backupfile" $PWD
    info "Backup listo."
}

function backup_app {
    info "Creando backup de los archivos de configuración."
    container=$old_andino
    backupdir=$(mktemp -d)
    today=`date +%Y-%m-%d.%H:%M:%S`
    appbackupdir="$backupdir/application/"
    mkdir $appbackupdir
    info "Iniciando backup de los volumenes en $container"
    info "Usando directorio temporal: $backupdir"
    docker inspect --format '{{json .Mounts}}' $container  | jq -r '.[]|[.Name, .Source, .Destination] | @tsv' |
    while IFS=$'\t' read -r name source destination; do
        info "Guardando archivos de $destination"
        if ls $source/* 1> /dev/null 2>&1; then
            info "Nombre del volumen: $name."
            info "Directorio en el Host: $source"
            info "Destino: $destination"
            dest="$appbackupdir$name"
            mkdir -p $dest
            echo "$destination" > "$dest/destination.txt"

            tar -C "$source" -zcvf "$dest/backup_$today.tar.gz" $(ls $source)
            info "List backup de $destination"
        else
            info "Ningún archivo para $destination";
        fi
    done
    info "Generando backup en $app_backup"
    tar -C "$appbackupdir../" -zcvf $app_backup "application/"
    info "Backup listo."
}

function install_andino {
    info "Descargando script de instalación."
    wget https://raw.github.com/datosgobar/portal-base/master/deploy/install.py
    info "Iniciando instalación."
    python ./install.py --error_email "$EMAIL" --site_host="$HOST" \
        --database_user="$DB_USER" --database_password="$DB_PASS" \
        --datastore_user="$STORE_USER" --datastore_password="$STORE_PASS"
}

function restore_files {
    info "Iniciando recuperación de Archivos."
    container="andino"
    containers=$(docker ps -q)
    docker stop $containers

    restoredir=$(mktemp -d)
    info "Usando directorio temporal $restoredir"
    tar zxvf $app_backup -C $restoredir

    docker inspect --format '{{json .Mounts}}' $container  | jq -r '.[]|[.Name, .Source, .Destination] | @tsv' |
    while IFS=$'\t' read -r name source destination; do
        for directory in $restoredir/application/*; do
            dest=$(cat "$directory/destination.txt")
            if [ "$dest" == "$destination" ]; then
                info "Recuperando archivos para $destination"
                tar zxvf "$directory/$(ls "$directory" | grep backup)" -C "$source"
            fi
        done
    done
    info "Restauración lista."
    info "Reiniciando servicios."
    docker restart $containers
}

function restore_db {
    info "Iniciando restauración de la base de datos."
    container="andino-db"
    containers=$(docker ps -q)
    docker stop $containers
    docker restart $container
    sleep 10;

    restoredir=$(mktemp -d);
    info "Usando directorio temporal $restoredir"

    restorefile="$restoredir/dump.sql";

    gzip -dkc < $database_backup > "$restorefile";
    info "Borrando base de datos actual."
    docker exec $container psql -U postgres -c "DROP DATABASE IF EXISTS ckan;"
    docker exec $container psql -U postgres -c "DROP DATABASE IF EXISTS datastore_default;"
    info "Restaurando la base de datos: $restorefile"
    cat "$restorefile" | docker exec -i $container psql -U postgres
    info "Recuperando credenciales de los usuarios"
    docker exec  $container psql -U postgres -c "ALTER USER $DB_USER WITH PASSWORD '$DB_PASS';"
    docker exec  $container psql -U postgres -c "ALTER USER $STORE_USER WITH PASSWORD '$STORE_PASS';"

    info "Restauración lista."
    info "Reiniciando servicios."
    docker restart $containers
}

function rebuild_search {
    info "Regenerando índices de búsqueda."
    docker exec andino /etc/ckan_init.d/run_rebuild_search.sh
    info "Listo."
}

info "Creando directorio de instalación: $install_dir"
mkdir -p $install_dir

cd $install_dir

backup_database;
backup_app;
docker stop $(docker ps -q)

install_andino;

restore_files;
restore_db;
sleep 5;
rebuild_search;
