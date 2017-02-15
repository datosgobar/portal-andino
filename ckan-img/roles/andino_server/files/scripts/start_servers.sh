#!/bin/bash
set -ue

service apache2 restart;
service supervisor restart;
