#!/bin/bash

set -e;

echo "Agregando clave SSH"
eval "$(ssh-agent -s)"
ssh-add /tmp/deployment@travis-ci.org

# Nota: Las variables no definidas aqui deben ser seteadas en ./variables.sh

# TODO: Mejorar este script.
echo "Ejecutando comando de instalación..."

# Actualizo el script de actualización
ssh $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "rm -rf ~/update.py ~/installation_manager.py"
scp -P $DEPLOY_TARGET_SSH_PORT "install/update.py install/installation_manager.py" "$DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP:~/"

ssh -t $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "sudo python ~/update.py --andino_version $DEPLOY_TAG $DEPLOY_SSL_ENABLE_FLAG --ssl_crt_path $DEPLOY_SSL_CRT_PATH --ssl_key_path $DEPLOY_SSL_KEY_PATH"
