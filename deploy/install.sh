#!/usr/bin/env bash
set -e;

sudo mkdir -p /etc/andino/

docker pull datosgobar/portal-andino:development-postgresql && \
        docker pull datosgobar/portal-andino:development-solr && \
        docker pull redis:3.2.7-alpine && \
        docker pull rabbitmq:3.6.6-alpine && \
        docker pull catatnight/postfix && \
        docker pull datosgobar/portal-andino:development-andino && \
        docker pull datosgobar/portal-andino:development-nginx;

docker run -d --name andino-postgresql datosgobar/portal-andino:development-postgresql && \
    docker run -d --name andino-solr datosgobar/portal-andino:development-solr && \
    docker run -d --name andino-redis redis:3.2.7-alpine && \
    docker run -d --name andino-rabbitmq -h rabbitmq rabbitmq:3.6.6-alpine && \
    docker run -d --name andino-postfix -p 25:25 -p 587:587 catatnight/postfix && \
    docker run -d --name andino -p 8800:8800 \
        --link andino-postgresql:db --link andino-solr:solr \
        --link andino-redis:redis --link andino-rabbitmq:rabbitmq \
        --link andino-postfix:postfix \
        datosgobar/portal-andino:development-andino && \
    docker run -d --name andino-nginx -p 80:80 --link andino:andino datosgobar/portal-andino:development-nginx;

# init database
docker exec andino /etc/ckan_init.d/init_db.sh

# Run Harvest
docker run -d --name andino-harvest datosgobar/portal-andino:development-andino \
        --link andino-postgresql:db --link andino-solr:solr \
        --link andino-redis:redis --link andino-rabbitmq:rabbitmq \
        --link andino-postfix:postfix \
        datosgobar/portal-andino:development-andino /etc/ckan_init.d/start_cron.sh
