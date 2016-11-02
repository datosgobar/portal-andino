#!/bin/bash
DHUB_USER="datosgobar"
CKAN_DI="ckan-distribuible" 
PG_DI="pg-ckan"
SOLR_DI="solr"


CKAN_APACHE2_PORT="80"
CKAN_DATAPUSHER_PORT="8800"

: ${CKAN_URL:=}
: ${CKAN_IP:=}

USER_DATA=" "

exec 3>&1
# Store data to $VALUES variable
VALUES=$(dialog --ok-label " Instalar " \
	  --cancel-label "Salir" \
	  --backtitle "Autodeploy de CKAN Distribuilble" \
	  --title "Instalar CKAN" \
	  --form "Complete los datos" \
11 60 0 \
"URL de CKAN: http://" 1 1	"$ckan_url"		1 21 45 0 \
"IP de CKAN: http://"  2 1	"$server_ip"	2 21 45 0 \
2>&1 1>&3)

# close fd
exec 3>&-


if [ -z $VALUES ] ; then
	clear
	echo "Saliendo de CKAN-Distribuible Autodeploy...." && sleep 2 && clear
else
	# Comienzo instalacion de CKAN
	clear && echo "Instalando..."
	USER_DATA=($VALUES)
	CKAN_URL=${USER_DATA[0]}
	CKAN_IP=${USER_DATA[1]}
	# Esta docker insalado?	
	printf "> Checkeando instalacion de Docker Engine ..."
	if [ $(dpkg-query -W -f='${Status}' docker-engine 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		# No? no importa, lo instalamos! :D
		printf "[FALLO]\Instalando Docker Engine ...\n"
		sudo su -c "curl -sSL https://get.docker.com | sh"
		printf "[DONE]\n"
	else
		printf "[OK]\n"
	fi
	printf "+ Bajando contenedores desde docker-hub ...\n"
	echo "$CKAN_DI $PG_DI $SOLR_DI" | xargs -n 1 | while read img; do docker rm -f $img; docker pull $DHUB_USER/$img:latest; done
	printf "+ Iniciando contenedores de Solr & PostgreSQL ...\n"
	echo "$PG_DI $SOLR_DI" | xargs -n 1 | while read img; do docker run -d  --name $img $DHUB_USER/$img; done
	printf "+ Iniciando contendor de CKAN\n"
	docker run -d --link $PG_DI:db --link $SOLR_DI:solr -p 80:$CKAN_APACHE2_PORT -p 8800:$CKAN_DATAPUSHER_PORT --name $CKAN_DI $DHUB_USER/$CKAN_DI:latest
	sleep 20
	echo "+ Configurando ckan-distribuible..."
	echo "++ Configurando $CKAN_URL..."
	docker exec -it $CKAN_DI /bin/bash -c "service apache2 stop"
	docker exec -it $CKAN_DI /bin/bash -c "service nginx stop"
	docker exec -it $CKAN_DI /bin/bash -c "/usr/lib/ckan/default/bin/paster --plugin=ckan config-tool /etc/ckan/default/production.ini -e 'ckan.site_url = http://$CKAN_URL' 'ckan.datapusher.url = http://$CKAN_IP:8800'"
	dialog --infobox "Bien! todo listo! bla.. bla.. bla.." 30 50 ; sleep 20; clear
	docker exec -it $CKAN_DI /bin/bash -c "/etc/ckan_init.d/start_ckan.sh"
fi

