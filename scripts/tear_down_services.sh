#!/usr/bin/env bash

if [[ -f /etc/portal/latest.yml ]];
then
    cd /etc/portal && docker-compose -f /etc/portal/latest.yml down && cd .. && sudo rm -rf /etc/portal/
else
    docker kill $(docker ps -q -f name=andino)
fi