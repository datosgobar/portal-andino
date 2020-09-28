#!/bin/bash
set -e;

# Considerando que CKAN/data va a ser un volumen externo, corrijo permisos
chown www-data:www-data /var/lib/ckan /usr/lib/ckan/default/src/ckanext-gobar-theme/ckanext/gobar_theme/public/user_images /var/lib/ckan/theme_config
chmod u+rwx /var/lib/ckan /usr/lib/ckan/default/src/ckanext-gobar-theme/ckanext/gobar_theme/public/user_images /var/lib/ckan/theme_config

APACHE_PID=/var/run/apache2/apache2.pid
printf  "Borrar si existe: apache2.pid ($APACHE_PID):....."
[ -e  "$APACHE_PID" ] && rm -f $APACHE_PID && printf "[OK eliminando apache2.pid]\n"

service apache2 stop
# reindexando solr
/usr/lib/ckan/default/bin/paster --plugin=ckan search-index rebuild --config=/etc/ckan/default/production.ini
exec /etc/ckan_init.d/run_andino.sh
