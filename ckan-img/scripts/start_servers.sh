#!/bin/bash
set -ue

# Si esta corriendo, detenemos Apache & NginX
service apache2 stop;
service nginx stop;
service redis-server stop;
service rabbitmq-server stop;
service supervisor stop;
service postfix stop;

# Volvemos a lanzar los servidores que requiere la app
nginx &
service apache2 restart;
service nginx restart;
service redis-server restart;
service rabbitmq-server restart;
service supervisor restart;
service postfix restart;