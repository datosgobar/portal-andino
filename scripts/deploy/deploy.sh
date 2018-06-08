#!/bin/bash

set -e;

echo "Agregando clave SSH"
eval "$(ssh-agent -s)"
ssh-add /tmp/deployment@travis-ci.org

# Nota: Las variables no definidas aqui deben ser seteadas en ./variables.sh

# TODO: Mejorar este script.
echo "Ejecutando comando de instalación..."

# Actualizo el script de actualización
ssh $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "rm -rf ~/update.py"
scp -P $DEPLOY_TARGET_SSH_PORT "install/update.py" "$DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP:~/update.py"

ssh -t $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "sudo python ~/update.py --andino_version $DEPLOY_TAG --branch=andino-2.5"
