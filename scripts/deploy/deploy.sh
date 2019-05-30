#!/bin/bash

set -e;

echo "Agregando clave SSH"
eval "$(ssh-agent -s)"
ssh-add /tmp/deployment@travis-ci.org

ENVIRONMENT="$1"

# Nota: Las variables no definidas aqui deben ser seteadas en ./variables.sh

# TODO: Mejorar este script.
echo "Ejecutando comando de instalación..."

# Actualizo el script de actualización
ssh $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "rm -rf ~/update.py ~/installation_manager.py"
scp -P $DEPLOY_TARGET_SSH_PORT "install/update.py" "$DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP:~/"
scp -P $DEPLOY_TARGET_SSH_PORT "install/installation_manager.py" "$DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP:~/"

if [[ $ENVIRONMENT = 'andino-dev' ]] ; then dev_domain='portal-andino-v3d.datos.gob.ar' ; elif [[ $ENVIRONMENT = 'datosgobar-dev' ]] ; then dev_domain='v3d.datos.gob.ar' ; fi
if [ -z $dev_domain ] ; then
    echo "Generando certificados para $dev_domain";
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/CN=$dev_domain/O=My Company Name LTD./C=AR" -keyout $DEPLOY_SSL_KEY_PATH -out $DEPLOY_SSL_CRT_PATH
fi

ssh -t $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "sudo python ~/update.py --andino_version $DEPLOY_TAG $DEPLOY_SSL_ENABLE_FLAG --ssl_crt_path $DEPLOY_SSL_CRT_PATH --ssl_key_path $DEPLOY_SSL_KEY_PATH"
