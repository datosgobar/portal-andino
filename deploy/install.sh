#!/usr/bin/env bash
set -e;

sudo mkdir -p /etc/andino/

curl -O https://raw.githubusercontent.com/datosgobar/portal-andino/development/lasted.yml
docker-compose -f lasted.yml up -d nginx

# init database
docker exec andino /etc/ckan_init.d/init_db.sh

# Run Harvest
docker-compose -f lasted.yml up -d start_harvest
