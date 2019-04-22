#!/bin/bash

set -e;

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
    echo "    serve             Usar un servidor de paster para debuguear fácilmente la aplicación en el puerto 5000"
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
    sub_exec supervisorctl restart all
    sub_create_admin admin;
}

sub_setup_with() {
    if [ -z "$1" ]; then
        echo "Falta el directorio a instalar."
        exit 1;
    fi
    directory="$1"
    sub_exec /usr/lib/ckan/default/bin/pip install -r "$directory/requirements.txt"
    sub_exec /usr/lib/ckan/default/bin/pip install -e "$directory"
    sub_exec /etc/ckan_init.d/init_dev.sh
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
    nginx_container=portalandino_nginx_1;
    echo "nginx"
    postfix_container=portalandino_postfix_1;
    # --link es legacy, eventualmente se deberá cambiar
    docker run -v "$src:$dest" \
        --link $redis_container:redis --link $db_container:db --link $nginx_container:nginx \
        --link $solr_container:solr --link $postfix_container:postfix \
        --network portalandino_default -it -p 8080:8080 -p 5000:5000 datosgobar/portal-base /bin/bash
}

sub_serve(){
    cd /etc/portal;
    docker-compose -f latest.yml exec portal bash -c \
    "/usr/lib/ckan/default/bin/paster serve /etc/ckan/default/debug.ini --reload";
}

generate_testing_arguments(){
    while true; do
        case $1 in
        -a | --andino_branch)
          shift
          andino_branch="$1"
          ;;
        -t | --theme_branch)
          shift
          theme_branch="$1"
          ;;
        -b | --base_branch)
          shift
          base_branch="$1"
          ;;
        --site_host)
          shift
          if ! [ -z "$1" ]
            then
              site_host="$1"
          fi
          ;;
        --nginx_ssl)
          nginx_ssl=" --nginx_ssl"
          ;;
        --nginx_host_port)
          shift
          if ! [ -z "$1" ]
            then
              nginx_host_port=" --nginx_port=$1"
          fi
          ;;
        --nginx_ssl_port)
          shift
          if ! [ -z "$1" ]
            then
              nginx_ssl_port=" --nginx_ssl_port=$1"
          fi
          ;;
        --nginx-extended-cache)
          nginx_extended_cache=" --nginx-extended-cache"
          ;;
        --ssl_key_path)
          shift
          if ! [[ -f $1 ]];
            then
              printf "\nEl path ingresado para ssl_key_path es inválido.\n"
              exit 1
            else
              ssl_key_path=" --ssl_key_path=$1"
          fi
          ;;
        --ssl_crt_path)
          shift
          if ! [[ -f $1 ]];
            then
              printf "\nEl path ingresado para ssl_crt_path es inválido.\n"
              exit 1
            else
              ssl_crt_path=" --ssl_crt_path=$1"
          fi
          ;;
        --file_size_limit)
          shift
          if ! [ -z "$1" ]
            then
              file_size_limit=" --file_size_limit=$1"
          fi
          ;;
        --theme_volume_src)
          shift
          if ! [ -z "$1" ]
            then
              theme_volume_src=" --theme_volume_src=$1"
          fi
          ;;
        -h | --help)
          complete_commands_usage
          ;;
        \?)
          echo "Invalid option: -$OPTARG" >&2
          exit 1
          ;;
        :)
          echo "Option -$OPTARG requires an argument." >&2
          exit 1
          ;;
        --)
          shift
          break
            ;;
        *)
          shift
          break
          ;;
        esac
        shift
    done

    if [ -z "$andino_branch" ]
      then
        andino_branch=master
    fi
}

sub_complete_up(){
    # Parámetros
    SHORTOPTS="a:t:b:h"
    LONGOPTS="andino_branch:,theme_branch:,base_branch:,site_host:,nginx_ssl,nginx_host_port:,nginx_ssl_port:,nginx-extended-cache,ssl_key_path:,ssl_crt_path:,file_size_limit:,theme_volume_src:,help"

    ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS -- "$@" )
    eval set -- "$ARGS"
    # Manejo de parámetros
    generate_testing_arguments $@

    printf "Utilizando el branch $andino_branch de portal-andino.\n"
    printf "Host port: $nginx_host_port - SSL port: $nginx_ssl_port.\n"
    printf "Path key: $ssl_key_path - Path crt: $ssl_crt_path.\n"
    if ! [ -z "$base_branch" ]
      then
        docker pull datosgobar/portal-base:"$base_branch" || true
        base_version_argument=" --build-arg IMAGE_VERSION=$base_branch"
    fi

    # Preparo variables
    printf "Preparando variables.\n"
    DIR=$( dirname "${BASH_SOURCE[0]}" )
    EMAIL=admin@example.com
    if [ -z "$site_host" ]
      then
        site_host=localhost
    fi
    HOST=$site_host
    DB_USER=my_database_user
    DB_PASS=my_database_pass
    STORE_USER=my_data_user
    STORE_PASS=my_data_pass
    PAT_DIR=/usr/lib/ckan/default/src/ckanext-gobar-theme

    # Se asume que ya se hizo el checkout al branch de portal-andino a testear, o que se está en master y se testeará
    # otro proyecto, y que no es necesario realizar un pull

    # Creo imagen de portal-andino
    printf "Creando imagen de portal-andino.\n"
    cd $DIR
    docker build -t datosgobar/portal-andino:$andino_branch $base_version_argument .

    # Instalo y levanto Andino
    printf "\nComenzando instalación.\n"
    cd $DIR/install
    sudo python2 ./install.py      \
        --error_email "$EMAIL" \
        --site_host="$HOST" \
        --database_user="$DB_USER"\
        --database_password="$DB_PASS"\
        --datastore_user="$STORE_USER"\
        --datastore_password="$STORE_PASS"\
        --andino_version=$andino_branch\
        --branch=$andino_branch\
        --use_local_compose_files\
        --theme_volume_src=$theme_volume_src\
        $nginx_ssl\
        $nginx_extended_cache\
        $nginx_host_port\
        $nginx_ssl_port\
        $ssl_key_path\
        $ssl_crt_path\
        $file_size_limit

    # Checkout al directorio donde está instalado Andino
    cd /etc/portal

    # Creo un usuario con nombre y contraseña 'admin'
    printf "\nCreando usuario administrador (username: admin, password: admin).\n"
    docker-compose -f latest.yml exec portal bash -c \
    "yes | /etc/ckan_init.d/paster.sh --plugin=ckan sysadmin add admin email=john@doe.com password=admin"

    # Especifico path del log de apache (los errores del portal se escribirán ahí)
    printf "\nEspecificando path del archivo de log para apache.\n"
    docker-compose -f latest.yml exec portal bash -c \
    "sed -i 's/\/proc\/self\/fd\/1/\/var\/log\/apache2\/error.log/g' /etc/apache2/sites-enabled/ckan_default.conf"

    # Genero otro archivo de configuración para debugueo mediante paster (apache no soporta "debug = true")
    printf "\Creando archivo de configuración 'debug.ini'.\n"
    docker-compose -f latest.yml exec portal bash -c \
    "cp /etc/ckan/default/production.ini /etc/ckan/default/debug.ini"
    docker-compose -f latest.yml exec portal bash -c \
    "sed -i 's/debug = false/debug = true/g' /etc/ckan/default/debug.ini"

    # Hago un checkout dentro del contenedor al branch de portal-andino-theme, si se especificó uno
    if [ -z "$theme_branch" ]
      then
        printf "\nSe utilizará el branch master de portal-andino-theme.\n"
      else
        printf "\nSe utilizará el branch $theme_branch de portal-andino-theme.\n"
        docker-compose -f latest.yml exec portal bash -c \
        "cd $PAT_DIR && git fetch && git checkout $theme_branch && git pull origin $theme_branch " \
        "&& pip install -e . && apachectl restart"
    fi
}

sub_complete_update(){
    # Parámetros
    SHORTOPTS="a:t:b:h"
    LONGOPTS="andino_branch:,theme_branch:,base_branch:,site_host:,nginx_ssl,nginx_host_port:,nginx_ssl_port:,nginx-extended-cache,ssl_key_path:,ssl_crt_path:,file_size_limit:,help"

    ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS -- "$@" )
    eval set -- "$ARGS"
    # Manejo de parámetros
    generate_testing_arguments $@

    printf "Utilizando el branch $andino_branch de portal-andino.\n"
    printf "Host port: $nginx_host_port - SSL port: $nginx_ssl_port.\n"
    printf "Path key: $ssl_key_path - Path crt: $ssl_crt_path.\n"
    if ! [ -z "$base_branch" ]
      then
        docker pull datosgobar/portal-base:"$base_branch"
        base_version_argument=" --build-arg IMAGE_VERSION=$base_branch"
    fi

    # Preparo variables
    printf "Preparando variables.\n"
    DIR=$( dirname "${BASH_SOURCE[0]}" )
    HOST=localhost
    PAT_DIR=/usr/lib/ckan/default/src/ckanext-gobar-theme
    if ! [ -z "$site_host" ]
      then
        site_host=" --site_host=$site_host"  # Le doy el formato de parámetros opcionales
    fi

    # Se asume que ya se hizo el checkout al branch de portal-andino a testear, o que se está en master y se testeará otro
    # proyecto, y que no es necesario realizar un pull

    # Creo o actualizo imagen de portal-andino
    printf "Creando imagen de portal-andino.\n"
    cd $DIR
    docker build -t datosgobar/portal-andino:$andino_branch $base_version_argument .

    # Actualizo Andino
    printf "\nComenzando actualización.\n"
    cd $DIR/install
    sudo python2 ./update.py       \
        --andino_version=$andino_branch\
        --branch=$andino_branch\
        $site_host\
        $nginx_ssl\
        $nginx_extended_cache\
        $nginx_host_port\
        $nginx_ssl_port\
        $ssl_key_path\
        $ssl_crt_path\
        $file_size_limit

    # Checkout al directorio donde está instalado Andino
    cd /etc/portal

    # Hago un checkout dentro del contenedor al branch de portal-andino-theme, si se especificó uno
    if [ -z "$theme_branch" ]
      then
        printf "\nSe utilizará el mismo branch de portal-andino-theme que se estaba usando.\n"
      else
        printf "\nSe utilizará el branch $theme_branch de portal-andino-theme.\n"
        docker-compose -f latest.yml exec portal bash -c \
        "cd $PAT_DIR && git fetch && git checkout $theme_branch && git pull origin $theme_branch " \
        "&& pip install -e . && apachectl restart"
    fi
}

complete_commands_usage() {
	cat <<EOM
Usage: $(basename "$0") [OPTION]...
  -h | --help                             mostrar ayuda
  -a | --andino_branch           VALUE    nombre del branch de portal-andino (default: master)
  -t | --theme_branch            VALUE    nombre del branch de portal-andino-theme (default: master o el ya utilizado)
  -b | --base_branch             VALUE    nombre del branch de portal-base
       --site_host               VALUE    nombre de dominio del portal (default: localhost)
       --nginx_host_port         VALUE    puerto a usar para HTTP
       --nginx_ssl                        activar la configuración de SSL
       --nginx_ssl_port          VALUE    puerto a usar para HTTPS
       --ssl_key_path            VALUE    path a la clave privada del certificado SSL
       --ssl_crt_path            VALUE    path al certificado SSL
       --nginx-extended-cache             activar la configuración de caché extendida de Nginx
       --file_size_limit         VALUE    tamaño máximo en MB para archivos de recursos (default: 300, máximo recomendado: 1024)
EOM
	exit 2
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
