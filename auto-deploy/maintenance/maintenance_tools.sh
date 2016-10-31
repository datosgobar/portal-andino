#!/bin/bash
clear

# CONFIGS
DHUB_USER="jsalgadowk"
CKAN_DI="ckan"
PG_DI="pg-ckan"
SOLR_DI="solr"
MAINTENACE_TIME="15 3 * * * "  

# FONT COLORS & STYLE :D
R="\x1B[31m"
G="\x1B[29m"
GG="\x1B[32m"
B="\x1B[34m"
Y="\x1B[33m"
W="\x1B[37m"
BL="\x1B[30m"
V="\x1B[35m"
C="\x1B[36m"
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

.get_ip(){
    echo $(ifconfig $(route | grep '^default' | grep -o '[^ ]*$') | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
}

.mostrar_ayuda (){
clear
printf \
"AYUDA:
======

USUARIOS:
Crear, listar o borrar usuarios de CKAN: --usuario=accion parametro o -u=accion parametro 

    Agregar usuario admin: --usuario=add nombre_de_usuario o -u=add nombre_de_usuario     
    Listar usuarios de CKAN: --usuario=listar o -u=listar     
    Borrar usuario: --usuario=del nombre_de_usuario o -u=del nombre_de_usuario    

CKAN:
Iniciar, detener, reiniciar o desinstalar CKAN: --ckan=accion o -ckan=accion 

    Iniciar CKAN: --ckan=start     
    Detener CKAN: --ckan=stop
    Reiniciar CKAN: --ckan=restart    
    Desinstalar CKAN: --ckan=remove

BASES DE DATOS:
Tareas de mantenimiento para las bases de datos de CKAN: --bases-de-datos=accion o -db=accion 

    Inicializar bases de datos de CKAN: --bases-de-datos=init o -db=init     
    Hacer dump de bases de CKAN: --bases-de-datos=dump /carpeta/dump.sql o -db=dump /carpeta/dump.sql 
    Limpiar Bases de Datos de CKAN: --bases-de-datos=clear o -db=clear

ACTUALIZACION:
Programar momento de actualizacion para contenedores de CKAN: --actualizacion=accion o -a=accion 

    Activar actualizacion: --actualizacion=start     
    Desactivar actualizacion: --actualizacion=stop

BACKUP:
Activar, desactivar backups automaticos para el contenido de CKAN: --backup=accion parametro o -bu=accion parametro 

    Activar backup: --backup=start /carpeta/de/destino o -bu=start /carpeta/de/destino      
    Desactivar backup: --backup=stop o -bu=stop
\n" 
}

abort () {
  echo "$@" >&2
  echo ""
  exit 1
}

.install_cron () {
    if [[ $# -gt 0 ]]; then
        cat <(crontab -l) <(echo "$1") | crontab -
    else
        abort "Imposible crear entrada en crontabs... "
    fi
}


.user_afunctions(){
    # ADD | DEL | LIST    
    printf "\nFunciones de adminstracion de usuarios\n"
    p_actions="add del list"
    [[ $p_actions =~ $1 ]] && echo "Accion: $1" || echo "Opcion no reconocida..."
    echo ""
}

# FUNCIONES DE APP(CKAN)
.app_afunctions(){
    # START | STOP | RESTART | REMOVE
    printf "\nFunciones de adminstracion de Aplicacion CKAN\n"
    p_actions="start stop restart remove"
    [[ $p_actions =~ $1 ]] && echo "Accion: $1" || echo "Opcion no reconocida..."
    echo ""
}


# Bindear ckan(inside-container --> Intenet)
.app_bind(){
    # Si no recibo un host, configuro el ip de la VM
    if [[ $# -eq 0 ]] ; 
        then
            HOST_TO_BIND=$(.get_ip)
    else
            HOST_TO_BIND=$1
    fi 
    docker exec -it $CKAN_DI service nginx stop
    docker exec -it $CKAN_DI service apache2 stop; 
    docker exec -it $CKAN_DI /usr/lib/ckan/default/bin/paster --plugin=ckan config-tool /etc/ckan/default/production.ini -e  "ckan.datapusher.url = http://${HOST_TO_BIND}:8800" "ckan.site_url = http://${HOST_TO_BIND}"
    docker exec -it $CKAN_DI service nginx start
    docker exec -it $CKAN_DI service apache2 start; 
}


.app_start(){
    # Lanzamos todo de nuevo:
    echo $PG_DI $SOLR_DI | xargs -n 1 | while read img; do docker run -d --name $img $DHUB_USER/$img:latest; done
    docker run -d --link solr:solr --link pg-ckan:db -p 80:80 -p 8800:8800 --name $CKAN_DI $DHUB_USER/$CKAN_DI:latest
    .app_bind
}

# FUNCIONES DE ACTUALIZACION
.update_afunctions(){
    # START | STOP | RUN   
    EXEC="NONE"
    printf "
\n
Funciones de Actualizacion:
==========================\n\n"
    p_actions="start stop run"
    [[ $p_actions =~ $1 ]] && EXEC=$1 || abort "Opcion no reconocida..."
    
    case $1 in
        "start")
        echo "Funciones de actualizacion [START]"
        echo "Instalando en crontabs: \"15 3 * * * sh maintenance_tools.sh -a=run\""
        cat <(crontab -l) <(echo "15 3 * * * sh maintenance_tools.sh -a=run") | crontab -
        ;;

        "stop")
        echo "Funciones de actualizacion [STOP]"
        cat <(crontab -l) | grep -v "maintenance_tools.sh" | crontab -
        ;;

        "run")
        echo "Funciones de actualizacion [RUN]"
        ;;
    esac
}

# Update gobAR Theme
.update_theme (){
    sudo docker exec -it ckan service apache2 stop 
    sudo docker exec -it ckan service nginx stop
    sudo docker exec -it ckan su -c "cd /usr/lib/ckan/default/src/ckanext-gobar-theme/ && git pull"
    sudo docker exec -it ckan service apache2 start 
    sudo docker exec -it service nginx start
}
# Instalar updates...
.update_install(){
:
}

# Correr actualizaciones.
.update_run(){
    .update_containers
    .update_theme
}

# Update de contenedores.
.update_containers(){
    # Elimino todos los contenedores:
    echo $CKAN_DI $PG_DI $SOLR_DI | xargs -n 1 | while read img; do docker rm -f $img; done
    # Pull a todos los contenedores:
    echo $CKAN_DI $PG_DI $SOLR_DI | xargs -n 1 | while read img; do docker pull $DHUB_USER/$img:latest; done
    # Run ckan... run! XD
    .app_start
}

.backup_afunctions(){
    # START | STOP
    printf "\nFunciones de adminstracion de backups\n"
    p_actions="start stop"
    [[ $p_actions =~ $1 ]] && echo "Accion: $1" || echo "Opcion no reconocida..."
    echo ""
}

.database_afunctions(){
    # INIT | DUMP | CLEAR    
    printf "\nFunciones de adminstracion de bases de datos\n"
    p_actions="init dump clear"
    [[ $p_actions =~ $1 ]] && echo "Accion: $1" || echo "Opcion no reconocida..."
    echo ""
}

valid_args (){
    for i in "$@"
    do
    :
    done

}


DEFAULT=NOT
ACTION="NONE"
VALUE="NONE"
POSIBLE_ACTIONS="-u=* --usuario=* a=* --actualizar=* -db=* --bases-de-datos=* -b=* --backup=* -h --help"

# [[ $POSIBLE_ACTIONS =~ $1 ]] && echo "" || abort "Opcion no reconocida..."

case $1 in
    -u=*|--usuario=*)
    ACTION="Usuarios"
    VALUE="${1#*=}"
    .user_afunctions $VALUE
    ;;

    -a=*|--actualizar=*)
    ACTION="Actualizacion"
    VALUE="${1#*=}"
    .update_afunctions $VALUE
    ;;

    -db=*|--bases-de-datos=*)
    ACTION="Base de Datos"
    VALUE="${1#*=}"
    .database_afunctions $VALUE
    ;;

    -ckan=*|--ckan=*)
    ACTION="CKAN"
    VALUE="${1#*=}"
    .app_afunctions $VALUE
    ;;

    -b=*|--backup=*)
    ACTION="Backup"
    VALUE="${1#*=}"
    .backup_afunctions $VALUE
    ;;

    -h | --help)
    ACTION="Ayuda"
    VALUE="Mostrar ayuda"
    .mostrar_ayuda
    ;;  
esac

E/bin/paster --plugin=ckan sysadmin add ckan_admin -c /etc/ckan/default/production.ini