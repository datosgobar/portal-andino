#!/bin/bash

ProgName=$(basename $0);
nginx_name="nginx"
dev_container="andino-dev"

sub_help(){
    echo "Uso: $ProgName <subcomando>"
    echo "Subcomandos:"
    echo "    build         Levanta los servicios"
    echo "    up SRC DEST   Levanta la aplicacion montando un directorio"
    echo "    setup         Instala el directorio con pip y levantar el server"
    echo "    exec          Ejecuta comandos en el contenedor"
    echo "    stop          Detiene todos los servicios (Todos los containers de hecho)"
    echo "    rm            Borra el contenedor de desarrollo"
    echo ""
}

sub_stop(){
    docker stop $(docker ps -q)
}

sub_build() {
    docker-compose -f dev.yml up --build -d $nginx_name
}

sub_rm() {
    docker rm -fv "$dev_container";
}

sub_exec() {
    docker exec -it "$dev_container" $@;
}

sub_setup() {
    if [ -z "$1" ]; then
        echo "Falta el directorio a instalar."
        exit 1;
    fi
    directory="$1"
    sub_exec /usr/lib/ckan/default/bin/pip install -r "$directory/dev-requirements.txt"
    sub_exec /usr/lib/ckan/default/bin/pip install -e "$directory"
    sub_exec /etc/ckan_init.d/init_dev.sh
    sub_exec /usr/lib/ckan/default/bin/paster serve /etc/ckan/default/production.ini
}

sub_up(){
    if [ -z "$1" ]; then
        echo "Falta source del directorio a montar."
        exit 1;
    fi
    if [ -z "$2" ]; then
        echo "Falta el destino del directorio."
        exit 1;
    fi
    src="$1"
    dest="$2"
    redis_container=portalandino_redis_1;
    db_container=portalandino_db_1;
    solr_container=portalandino_solr_1;
    postfix_container=portalandino_postfix_1;
    docker run -v "$src:$dest" --name "$dev_container"\
        --link $redis_container:redis --link $db_container:db \
        --link $solr_container:solr --link $postfix_container:postfix \
        --network portalandino_default -it -p 8080:8080 -p 5000:5000 datosgobar/portal-base /bin/bash
}

subcommand=$1
case $subcommand in
    "" | "-h" | "--help")
        sub_help
        ;;
    *)
        shift
        sub_${subcommand} $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' no es un subcomando conocido." >&2
            echo "       Corre '$ProgName --help' para listar los comandos." >&2
            exit 1
        fi
        ;;
esac
