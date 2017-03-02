#!/usr/bin/env bash
set -e;

sudo mkdir -p /etc/andino/

sudo su -c "curl -sSL https://raw.github.com/datosgobar/portal-andino/lasted.yml | sh"
docker-compose -f lasted.yml up -d nginx

# init database
docker exec andino /etc/ckan_init.d/init_db.sh

# Run Harvest
docker-compose -f lasted.tml up -d start_harvest
