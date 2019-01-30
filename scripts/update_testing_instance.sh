#!/usr/bin/env bash

set -e;

# Parámetros
SHORTOPTS="a:t:b:h"
LONGOPTS="andino_branch:,theme_branch:,base_branch:,nginx_ssl,nginx_host_port:,nginx_ssl_port:,nginx-extended-cache,ssl_key_path:,ssl_crt_path:,help"

ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS -- "$@" )
eval set -- "$ARGS"
# Script para manejo de parámetros (lo corremos en el mismo shell, para que puedan usar las mismas variables)
. ./generate_testing_arguments.sh

printf "Utilizando el branch $andino_branch de portal-andino.\n"
printf "Host port: $nginx_host_port - SSL port: $nginx_ssl_port.\n"
printf "Path key: $ssl_key_path - Path crt: $ssl_crt_path.\n"
if ! [ -z "$base_branch" ]
  then
    base_version_argument=" --build-arg IMAGE_VERSION=release-$base_branch"
fi

# Preparo variables
printf "Preparando variables.\n"
DIR=$(dirname $(pwd))
EMAIL=admin@example.com
HOST=localhost
DB_USER=my_database_user
DB_PASS=my_database_pass
STORE_USER=my_data_user
STORE_PASS=my_data_pass
PAT_DIR=/usr/lib/ckan/default/src/ckanext-gobar-theme

# Se asume que ya se hizo el checkout al branch de portal-andino a testear, o que se está en master y se testeará otro
# proyecto, y que no es necesario realizar un pull

# Instalo y levanto Andino
printf "\nComenzando instalación.\n"
cd $DIR/install
sudo python ./update.py       \
    --andino_version=$andino_branch\
    --branch=$andino_branch\
    $nginx_ssl\
    $nginx_extended_cache\
    $nginx_host_port\
    $nginx_ssl_port\
    $ssl_key_path\
    $ssl_crt_path

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

# Se ingresa al contenedor
printf "\nIngresando al contenedor de Andino.\n"
docker-compose -f latest.yml exec portal bash