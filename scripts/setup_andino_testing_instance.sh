#!/usr/bin/env bash

set -e;

# Parámetros
PA_BRANCH_TO_TEST=$1
PAT_BRANCH_TO_TEST=$2

# Preparo variables
DIR=$(dirname $(pwd))
EMAIL=admin@example.com
HOST=localhost
DB_USER=my_database_user
DB_PASS=my_database_pass
STORE_USER=my_data_user
STORE_PASS=my_data_pass
PAT_DIR=/usr/lib/ckan/default/src/ckanext-gobar-theme

# Se asume que ya se hizo el checkout al branch de portal-andino a testear, o que se está en master y se testeará otra
# parte de Andino, y que no es necesario realizar un pull

# Creo imagen de portal-andino
cd $DIR
docker build -t datosgobar/portal-andino:$PA_BRANCH_TO_TEST .

# Instalo y levanto Andino
cd $DIR/install
sudo python ./install.py      \
    --error_email "$EMAIL" \
    --site_host="$HOST" \
    --database_user="$DB_USER"\
    --database_password="$DB_PASS"\
    --datastore_user="$STORE_USER"\
    --datastore_password="$STORE_PASS"\
    --andino_version=$PA_BRANCH_TO_TEST\
    --branch=$PA_BRANCH_TO_TEST

# Checkout al directorio donde está instalado Andino
cd /etc/portal

# Creo un usuario con nombre y contraseña 'admin'
docker-compose -f latest.yml exec portal bash -c \
"yes | /etc/ckan_init.d/paster.sh --plugin=ckan sysadmin add admin email=cdigiorno@devartis.com password=admin"

# Especifico path del log de apache (los errores del portal se escribirán ahí)
docker-compose -f latest.yml exec portal bash -c \
"sed -i 's/\/proc\/self\/fd\/1/\/var\/log\/apache2\/error.log/g' /etc/apache2/sites-enabled/ckan_default.conf"

# Hago un checkout dentro del contenedor al branch de portal-andino-theme, si se especificó uno
if [ -z "$2" ]
  then
    echo "Se utilizará el branch master de portal-andino-theme"
  else
    echo "Se utilizará el branch $PAT_BRANCH_TO_TEST de portal-andino-theme"
    docker-compose -f latest.yml exec portal bash -c \
    "cd $PAT_DIR && git fetch && git checkout $PAT_BRANCH_TO_TEST && git pull origin $PAT_BRANCH_TO_TEST " \
    "&& pip install -e . && apachectl restart"
fi

# Se ingresa al contenedor
docker-compose -f latest.yml exec portal bash