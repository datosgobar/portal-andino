#!/bin/bash
#Lanzamos servidores requeridos para que funciones Harvest en Background


set -eu

abort () {
  echo "$@" >&2
  exit 1
}
#Lanzo servidor de Redis
service redis-server start 
if [ $? -eq 0  ] then
	service rabbitmq-server start
	if [ $? -eq 0 ] then
		service supervisor start
			if [ $? -eq 0 ] then
				service supervisor start 
				supervisorctl reread
				supervisorctl add ckan_gather_consumer
				supervisorctl add ckan_fetch_consumer
				supervisorctl start ckan_gather_consumer
				supervisorctl start ckan_fetch_consumer
			else
				abort "Fallo inicio de Supervisor..."
			fi
	else
		abort "Fallo inicio de Rabbitmq-Server..."
	fi
else
   abort "Fallo inicio de Redis-Server..."
fi

# RUN HARVEST-JOBS
# */15 *  *   *   *     /usr/lib/ckan/default/bin/paster --plugin=ckanext-harvest harvester run --config=/etc/ckan/default/production.ini
# 0  5  *   *   *     /usr/lib/ckan/default/bin/paster --plugin=ckanext-harvest harvester clean_harvest_log --config=/etc/ckan/default/production.ini
