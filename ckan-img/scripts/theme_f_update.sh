#!/bin/bash

###################################################################
#                                                                 #
#       Reset de servidores para la cargar de configuracion       # 
#                    del Usuario GOBAR-THEME                      #
#                                                                 #
###################################################################

while true;
do
	while inotifywait -q -e modify /var/lib/ckan/theme_config/settings.json >/dev/null; do
	    echo "[$(date +%Y-%m-%dT%H:%M:%SZ)] INFO: Cambio en GobAr Theme." > /var/log/ckan/theme.changes.log
	    service apache2 reload;
	    service nginx stop;
	    nginx &
	done
done
