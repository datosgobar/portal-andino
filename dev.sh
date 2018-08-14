#!/bin/bash

ProgName=$(basename $0);

sub_help(){
    echo "Uso: $ProgName <subcomando>"
    echo "Subcomandos:"
    echo "    build             Generar las imágenes necesarias para los servicios"
    echo "    up                Levantar los servicios"
    echo "    stop              Parar los servicios"
    echo "    down              Borra los contenedores y los volúmenes"
    echo "    rm                Borrar los contenedores de los servicios"
    echo "    exec              Ejecuta comandos en el contenedor"
    echo "    create_admin      Crear un usuario administrador"
    echo "    setup             Inicializar la base de datos y un admin"
    echo "    up_with SRC DEST  Levanta la aplicacion montando un directorio"
    echo "    setup_with        Instala el directorio con pip y levantar el server"
    echo ""
}

sub_compose() {
    docker-compose -f dev.yml $@;
}

sub_stop(){
    sub_compose stop $@;
}

sub_down(){
    sub_compose down -v;
}

sub_build() {
    sub_compose build;
}

sub_rm() {
    sub_compose rm $@;
}

sub_exec() {
    sub_compose exec portal $@;
}

sub_console() {
    sub_exec /bin/bash;
}

sub_up(){
    sub_compose up -d $@;
}

sub_logs(){
    sub_compose logs -f portal;
}


sub_create_admin() {
    sub_exec /etc/ckan_init.d/add_admin.sh $@ info@example.com;
}

sub_setup() {
    sub_exec /etc/ckan_init.d/init_dev.sh;
    sub_exec chown www-data:www-data /usr/lib/ckan/default/src/ckan/ckan/public/base/i18n/ar.js
    sub_exec supervisorctl restart all
    sub_create_admin admin;
}

sub_setup_with() {
    if [ -z "$1" ]; then
        echo "Falta el directorio a instalar."
        exit 1;
    fi
    directory="$1"
    sub_exec /usr/lib/ckan/default/bin/pip install -r "$directory/dev-requirements.txt"
    sub_exec /usr/lib/ckan/default/bin/pip install -e "$directory"
    sub_exec /etc/ckan_init.d/init_dev.sh
    chown www-data:www-data /usr/lib/ckan/default/src/ckan/ckan/public/base/i18n/ar.js
    sub_exec supervisorctl restart all
    sub_exec /usr/lib/ckan/default/bin/paster serve /etc/ckan/default/production.ini
}

sub_up_with(){
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
    docker run -v "$src:$dest" \
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
