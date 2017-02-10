#!/bin/bash
set -ue

service apache2 restart;
service redis-server restart;
service rabbitmq-server restart;
service supervisor restart;
service postfix restart;