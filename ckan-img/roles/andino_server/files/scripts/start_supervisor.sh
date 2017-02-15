#!/bin/bash
#Lanzamos servidores requeridos para que funciones Harvest en Background


set -eu

abort () {
  echo "$@" >&2
  exit 1
}

service supervisor restart
if [ $? -eq 0 ] then
	supervisorctl reread
	supervisorctl add ckan_gather_consumer
	supervisorctl add ckan_fetch_consumer
	supervisorctl start ckan_gather_consumer
	supervisorctl start ckan_fetch_consumer
else
	abort "Fallo inicio de Supervisor..."
fi
