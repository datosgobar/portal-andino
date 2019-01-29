#!/usr/bin/env bash

set -e;

usage() {
	cat <<EOM
Usage: $(basename "$0") [OPTION]...

  -h | --help                             mostrar ayuda
  -a | --andino_branch           VALUE    nombre del branch de portal-andino (default: master)
  -t | --theme_branch            VALUE    nombre del branch de portal-andino-theme (default: master o el ya utilizado)
  -b | --base_branch             VALUE    nombre del branch de portal-base
       --nginx_ssl                        activar la configuración de SSL
       --nginx_host_port         VALUE    puerto a usar para HTTP
       --nginx_ssl_port          VALUE    puerto a usar para HTTPS
       --nginx-extended-cache             activar la configuración de caché extendida de Nginx
       --ssl_key_path            VALUE    path a la clave privada del certificado SSL
       --ssl_crt_path            VALUE    path al certificado SSL
EOM
	exit 2
}

while true; do
	case $1 in
	-a | --andino_branch)
	  shift
	  andino_branch="$1"
      ;;
	-t | --theme_branch)
	  shift
	  theme_branch="$1"
      ;;
	-b | --base_branch)
	  shift
	  base_branch="$1"
      ;;
	--nginx_ssl)
	  nginx_ssl=" --nginx_ssl"
      ;;
	--nginx_host_port)
	  shift
	  nginx_host_port=" --nginx_port=$1"
      ;;
	--nginx_ssl_port)
	  shift
	  nginx_ssl_port=" --nginx_ssl_port=$1"
      ;;
	--nginx-extended-cache)
	  nginx_extended_cache=" --nginx-extended-cache"
      ;;
	--ssl_key_path)
	  shift
	  if ! [[ -f $1 ]];
        then
          printf "\nEl path ingresado para ssl_key_path es inválido.\n"
          exit 1
        else
          ssl_key_path="--ssl_key_path=$1"
      fi
      ;;
	--ssl_crt_path)
	  shift
	  if ! [[ -f $1 ]];
        then
          printf "\nEl path ingresado para ssl_crt_path es inválido.\n"
          exit 1
        else
          ssl_crt_path="--ssl_crt_path=$1"
      fi
      ;;
	-h | --help)
	  usage
      ;;
	\?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    --)
      shift
      break
        ;;
    *)
      shift
      break
      ;;
	esac
	shift
done

if [ -z "$andino_branch" ]
  then
    andino_branch=master
fi