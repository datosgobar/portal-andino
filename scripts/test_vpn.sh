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

echo "Chequeo de mtu"
ifconfig

echo "Busco un valor adecuado de MTU"
ping -M do -s 1500 -c 1 $DEPLOY_TARGET_IP
ping -M do -s 1490 -c 1 $DEPLOY_TARGET_IP
ping -M do -s 1480 -c 1 $DEPLOY_TARGET_IP
ping -M do -s 1470 -c 1 $DEPLOY_TARGET_IP
ping -M do -s 1460 -c 1 $DEPLOY_TARGET_IP
ping -M do -s 1450 -c 1 $DEPLOY_TARGET_IP
ping -M do -s 1440 -c 1 $DEPLOY_TARGET_IP
ping -M do -s 1430 -c 1 $DEPLOY_TARGET_IP
ping -M do -s 1420 -c 1 $DEPLOY_TARGET_IP
ping -M do -s 1410 -c 1 $DEPLOY_TARGET_IP
ping -M do -s 1400 -c 1 $DEPLOY_TARGET_IP

echo "Bajo valor de MTU para tun0"
sudo ifconfig tun0 mtu 578

echo "Chequeo de mtu"
ifconfig

echo "Running remote ls command"
ssh -t $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "ls -lsa"

echo "Running remote command"
ssh -t $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "echo 'Hello world'"

echo "Running remote command"
ssh -t $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "whoami && hostname"

echo "Copying a file without scp"
cat install/update.py | ssh $DEPLOY_TARGET_USERNAME@$DEPLOY_TARGET_IP -p$DEPLOY_TARGET_SSH_PORT "cat > ~/update.py"
