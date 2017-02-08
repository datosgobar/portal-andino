#!/bin/bash
set -ue

service nginx stop;
nginx &
service apache2 restart;
service nginx restart;
service redis-server restart;
service rabbitmq-server restart;
service supervisor restart;
service postfix restart;