#!/usr/bin/env bash

if [[ -f /etc/portal/latest.yml ]];
then
    cd /etc/portal && docker-compose -f /etc/portal/latest.yml down && cd .. && sudo rm -rf /etc/portal/
else
    if [[ $(docker ps -q -f name=andino) ]];
    then
        docker kill $(docker ps -q -f name=andino)
    else
        echo "No hay contenedores de Andino corriendo."
    fi
fi