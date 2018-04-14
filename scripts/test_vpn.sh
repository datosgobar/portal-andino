#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ENVIRONMENT="$1"

echo "Corriendo pruebas de VPN para $ENVIRONMENT";

echo "Inicializando"
. "$DIR/deploy/variables.sh" "$ENVIRONMENT"
echo "Setup"
"$DIR/deploy/prepare.sh"

echo "Agregando clave SSH"
eval "$(ssh-agent -s)"
ssh-add /tmp/deployment@travis-ci.org

echo "Pinging target server"
ping $DEPLOY_TARGET_IP -c 4

echo "Estado del servicio openvpn"
sudo service openvpn status

echo "Running remote ls command"
ssh -t $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "ls -lsa"

echo "Running remote command"
ssh -t $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "echo 'Hello world'"

echo "Running remote command"
ssh -t $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "whoami && hostname"

echo "Copying a file"
scp -P $DEPLOY_TARGET_SSH_PORT "install/update.py" "$DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP:~/update.py"
