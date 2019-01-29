#!/usr/bin/env bash

set -e;

# Parámetros
while getopts "a:t:b:" opt;do
	case "$opt" in
	a)
	  andino_branch="$OPTARG"
      ;;
	t)
	  theme_branch="$OPTARG"
      ;;
	b)
	  base_branch="$OPTARG"
      ;;
	\?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
	esac
done
if [ -z "$andino_branch" ]
  then
    andino_branch=master
fi
printf "Utilizando el branch $andino_branch de portal-andino.\n"

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

# Creo imagen de portal-andino
printf "Creando imagen de portal-andino.\n"
cd $DIR
docker build -t datosgobar/portal-andino:$andino_branch .

# Instalo y levanto Andino
printf "\nComenzando instalación.\n"
cd $DIR/install
sudo python ./install.py      \
    --error_email "$EMAIL" \
    --site_host="$HOST" \
    --database_user="$DB_USER"\
    --database_password="$DB_PASS"\
    --datastore_user="$STORE_USER"\
    --datastore_password="$STORE_PASS"\
    --andino_version=$andino_branch\
    --branch=$andino_branch

# Checkout al directorio donde está instalado Andino
cd /etc/portal

# Creo un usuario con nombre y contraseña 'admin'
printf "\nCreando usuario administrador (username: admin, password: admin).\n"
docker-compose -f latest.yml exec portal bash -c \
"yes | /etc/ckan_init.d/paster.sh --plugin=ckan sysadmin add admin email=cdigiorno@devartis.com password=admin"

# Especifico path del log de apache (los errores del portal se escribirán ahí)
printf "\nEspecificando path del archivo de log para apache.\n"
docker-compose -f latest.yml exec portal bash -c \
"sed -i 's/\/proc\/self\/fd\/1/\/var\/log\/apache2\/error.log/g' /etc/apache2/sites-enabled/ckan_default.conf"

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

# Se ingresa al contenedor
printf "\nIngresando al contenedor de Andino.\n"
docker-compose -f latest.yml exec portal bash