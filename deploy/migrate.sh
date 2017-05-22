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
    echo "EMAIL, HOST, DB_USER, DB_PASS, STORE_USER, STORE_PASS"

}


if [ -z "$EMAIL" ] || [ -z "$HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$STORE_USER" ] || [ -z "$STORE_PASS" ]; then
    echo "Falta una variable de entorno."
    usage
    exit 1;
fi



function backup_database {
    today=`date +%Y-%m-%d.%H:%M:%S`
    container=$old_db
    backupdir=$(mktemp -d)
    backupfile="$backupdir/$database_backup"
    echo "Directorio temporal: $backupdir"
    docker exec $container pg_dumpall -c -U postgres | gzip > "$backupfile"
    echo "Copiando a $PWD"
    cp "$backupfile" $PWD
}

function backup_app {
    container=$old_andino
    backupdir=$(mktemp -d)
    echo "Directorio temporal: $backupdir"
    today=`date +%Y-%m-%d.%H:%M:%S`
    appbackupdir="$backupdir/application/"
    mkdir $appbackupdir

    docker inspect --format '{{json .Mounts}}' $container  | jq -r '.[]|[.Name, .Source, .Destination] | @tsv' |
    while IFS=$'\t' read -r name source destination; do

        if ls $source/* 1> /dev/null 2>&1; then
            echo "Guardando: $name."
            echo "Fuente: $source"
            echo "Destino: $destination"
            dest="$appbackupdir$name"
            mkdir -p $dest
            echo "$destination" > "$dest/destination.txt"

            tar -C "$source" -zcvf "$dest/backup_$today.tar.gz" $(ls $source)
        else
            echo "Ningun archivo en el directorio $source"
        fi
    done

    tar -C "$appbackupdir../" -zcvf $app_backup "application/"
}

function install_andino {

    wget https://raw.github.com/datosgobar/portal-base/master/deploy/install.py
    python ./install.py --error_email "$EMAIL" --site_host="$HOST" \
        --database_user="$DB_USER" --database_password="$DB_PASS" \
        --datastore_user="$STORE_USER" --datastore_password="$STORE_PASS"
}

function restore_files {
    container="andino"
    containers=$(docker ps -q)
    docker stop $containers

    restoredir=$(mktemp -d)
    echo "Directorio temporal: $restoredir"
    tar zxvf $app_backup -C $restoredir

    docker inspect --format '{{json .Mounts}}' $container  | jq -r '.[]|[.Name, .Source, .Destination] | @tsv' |
    while IFS=$'\t' read -r name source destination; do
        for directory in $restoredir/application/*; do
            dest=$(cat "$directory/destination.txt")
            echo "Dest: dest"
            echo "Destination: $destination"
            if [ "$dest" == "$destination" ]; then
                tar zxvf "$directory/$(ls "$directory" | grep backup)" -C "$source"
            fi
        done
    done

    docker restart $containers
}

function restore_db {
    container="andino-db"
    containers=$(docker ps -q)
    docker stop $containers
    docker restart $container
    sleep 10;

    restoredir=$(mktemp -d);
    echo "Directorio temporal: $restoredir"

    restorefile="$restoredir/dump.sql";

    gzip -dkc < $database_backup > "$restorefile";
    echo "Borrando base de datos actual."
    docker exec $container psql -U postgres -c "DROP DATABASE IF EXISTS ckan;"
    docker exec $container psql -U postgres -c "DROP DATABASE IF EXISTS datastore_default;"
    echo "Restaurando la base de datos: $restorefile"
    cat "$restorefile" | docker exec -i $container psql -U postgres

    docker exec  $container psql -U postgres -c "ALTER USER $DB_USER WITH PASSWORD '$DB_PASS';"
    docker exec  $container psql -U postgres -c "ALTER USER $STORE_USER WITH PASSWORD '$STORE_PASS';"

    docker restart $containers
}

function rebuild_search {
    docker exec andino /etc/ckan_init.d/run_rebuild_search.sh
}

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