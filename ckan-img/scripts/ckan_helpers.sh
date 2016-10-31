: ${DATABASE_URL:=}
: ${SOLR_URL:=}
: ${ERROR_EMAIL:=}

set -eu

CKAN_PASTER=$CKAN_HOME/bin/paster
CKAN_PIP=$CKAN_HOME/bin/pip 

# Configuracion actual [/etc/ckan/default/nombre.ini]
CONFIG="${CKAN_CONFIG}/${CKAN_CONFIG_FILE}"

abort() {
  echo "$@" >&2
  exit 1
}

write_config () {
  echo "Creando configuracion para: ${CONFIG}"
  "$CKAN_HOME"/bin/paster make-config ckan "$CONFIG"

  "$CKAN_PASTER" --plugin=ckan config-tool "$CONFIG" -e \
		"sqlalchemy.url=${DATABASE_URL}" \
		"solr_url=${SOLR_URL}" \
		"ckan.storage_path = /var/lib/ckan" \
		"ckan.plugins = stats text_view image_view recline_view hierarchy_display hierarchy_form gobar_theme"  \
		"ckan.auth.create_user_via_api = false" \
		"ckan.auth.create_user_via_web = false" \
		"ckan.locale_default = es" \
		"'ckan.site_id' = default" \
		"email_to = disabled@example.com" \
		"error_email_from = ckan@$(hostname -f)" \
		"ckan.site_url = http://127.0.0.1"

  if [ -n "$ERROR_EMAIL" ]; then
    sed -i -e "s&^#email_to.*&email_to = ${ERROR_EMAIL}&" "$CONFIG"
  fi
}

link_postgres_url() {
  	local user=$DB_ENV_POSTGRES_USER
  	local pass=$DB_ENV_POSTGRES_PASS
  	local db=$DB_ENV_POSTGRES_DB
  	local host=$DB_PORT_5432_TCP_ADDR
  	local port=$DB_PORT_5432_TCP_PORT
  	echo "postgresql://${user}:${pass}@${host}:${port}/${db}"
}

link_solr_url() {
	local host=$SOLR_PORT_8983_TCP_ADDR
  	local port=$SOLR_PORT_8983_TCP_PORT
  	echo "http://${host}:${port}/solr/ckan"
}



#####################################
#                                   #
#        ADMIN CKAN FUNCTIONS!      #
#                                   #
#####################################

ckan_ayuda(){
	printf "Herramientas amigables de CKAN:\n"
	printf "==============================\n"
	printf "ckan_list_users:\n\t Listar todos los usuarios de posee actualmente CKAN\n\tUso: $ ckan_list_users"
	printf "ckan_add_admin:\n\t Crear un usuario administrador para ckan\n\tUso: $ ckan_add_admin \"nombre_de_usuario\" o $ ckan_add_admin"
	printf "ckan_init_db:\n\tInicializa las bases de datos de CKAN, version simplificada de \"$ paster  --plugin=ckan db init -c  /archivo/de/configuracion.ini\"\n\tUso $ ckan_init_db"
	printf "publicar_ckan:\n\tActualiza la url del sitio, puede usarse con IP o URLs\n\tUso: $ publicar_ckan xxx.xxx.xxx.xxx o $ publicar_ckan www.mihost.xxx"
	printf "ckan_build_context:\n\tCrea contexto funcional para CKAN\n\tUso: $ ckan_build_context"
	printf "write_config:\n\tCrea archivo de configuracion para CKAN\n\tUso $write_config \"/nuevo/archivo/de/configuracion.ini\""
	printf "ckan_ayuda\n\tMuestra ayuda sobre las herramientas amigables de CKAN."
}

# Listar usuarios todos de CKAN
ckan_list_users (){
	"$CKAN_PASTER" --plugin=ckan user list -c "$CONFIG"
}


# Crear usuario admin de CKAN!
ckan_add_admin(){
	ADMIN_NAME="ckan_admin"
	if [ "$#" -gt "0" ]; then
		ADMIN_NAME=$1
	fi
	# mkconfig
	"$CKAN_PASTER" --plugin=ckan sysadmin add $ADMIN_NAME -c "$CONFIG"
	if [ "$#" -gt "0" ]; then
		abort "ERR_MSG"
	fi 
}

# Inicializar la base de datos "Default"
ckan_init_db(){
	"$CKAN_PASTER" --plugin=ckan db init -c "$CONFIG"
	if [ "$?" -gt "0" ]; then
		abort "Fallo Inicializacion de DB :("		
	fi
}

#
ckan_start(){
	echo "Foo Text!"
}

ckan_build_context(){
	if [ ! -e "$CONFIG" ]; then
	  if [ -z "$DATABASE_URL" ]; then
	    if ! DATABASE_URL=$(link_postgres_url); then
	      abort "DATABASE_URL no encontrado..."
	    fi
	  fi
	  if [ -z "$SOLR_URL" ]; then
	    if ! SOLR_URL=$(link_solr_url); then
	      abort "SOLR_URL No encontrado..."
	    fi
	  fi
	  write_config
	fi
}

publicar_ckan (){
	HOST_TO_BIND=HOST_TO_BIND=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
	if [[ $# -gt 0 ]] ; 
		then
			# Si recibo un host lo uso, si no, configuro el ip(publica) de la VM
			HOST_TO_BIND=$1
	fi
	service apache2 stop && service nginx stop 
	/usr/lib/ckan/default/bin/paster --plugin=ckan config-tool /etc/ckan/default/production.ini -e \
		"ckan.datapusher.url = http://${HOST_TO_BIND}:8800" \
		"ckan.site_url = http://${HOST_TO_BIND}"
	service apache2 start && service nginx start

}

fooTest(){
	echo "friendly-ckan tools instaladas!"
	ckan_ayuda
} 

fooTest