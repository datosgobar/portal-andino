#!/bin/bash
set -ue

service apache2 restart;
service rabbitmq-server restart;
service supervisor restart;
