#!/bin/bash

# ----------------------------------------------------- # 
#  Finalizado el Build del contenedor en "run-mode"
#  debemos hacer algunas cosas para que todo funcione
#  correctamente. 
# ----------------------------------------------------- #

APACHE2_WSGI=$CKAN_CONFIG/apache.wsgi

# Creamos contexto para CKAN
/bin/bash $CKAN_INIT/.make_conf.sh
mconf=$?

# Inicializamos la Base de datos e incluso, Solr.
/bin/bash $CKAN_INIT/.init_db.sh
idb=$?

# Inicializamos la Base de datos e incluso, Solr.
/bin/bash $CKAN_INIT/start_servers.sh

exit_code=$(($mconf + $idb))

# Ambos commandos anteriores, fueron exitosos?
if [ "$exit_code" -eq "0" ] ; then

	# Forzamos la seleccion de nuestra configuracion actual dentro de WSGI 
	sed "s/production.ini/$CKAN_CONFIG_FILE/g" $CKAN_CONFIG/apache.wsgi > temp.f && mv temp.f $CKAN_CONFIG/apache.wsgi  	

	# Considerando que CKAN/data va a ser un volumen externo, corrijo permisos
	chown www-data:www-data $CKAN_DATA
	chmod u+rwx $CKAN_DATA
	service apache2 reload;
	service nginx reload;
	# Conectamos los logs de ckan con la salida de "docker logs"
	tail  -f /var/log/apache/ckan_default.error.log
	# Si por alguna razon fallan los logs detenemos CKAN-APACHE, el contenedor seguira vivo y funcional
	while true; do sleep 1000; done


else
	# Ok.. el mundo ya no es un lugar amigable!
	echo "-------------------------------------------"
	echo "  Ooops! hubo un problema.. :( " 
	echo "-------------------------------------------"
fi