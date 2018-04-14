#!/usr/bin/env bash

ENVIRONMENT="$1"

# NOTA: para agregar un nuevo ambiente, se necesitan todas estas variables,
# pero usando otros prefijos (en testing es TESTING_* )

export OVPN_CONFIG="client"
export OVPN_PATH="/etc/openvpn/$OVPN_CONFIG.conf"

# Las siguientes variables definen cuales variables buscar para desencriptar
# algunos valores de travis. Ver ./prepare.sh para mas info

DEFAULT_MTU_VALUE=578

if [ "$ENVIRONMENT" == "datosgobar-dev" ]; then
    echo "Ambiente $ENVIRONMENT"

    export USE_VPN="1"

    export DEPLOY_TARGET_SSH_PORT="$DATOSGOBAR_DEV_DEPLOY_TARGET_SSH_PORT"
    export DEPLOY_TARGET_USERNAME="$DATOSGOBAR_DEV_DEPLOY_TARGET_USERNAME"
    export DEPLOY_TARGET_IP="$DATOSGOBAR_DEV_DEPLOY_TARGET_IP"
    export DEPLOY_ENVIRONMENT="$ENVIRONMENT"
    export MTU_VALUE="${DATOSGOBAR_DEV_MTU_VALUE:-DEFAULT_MTU_VALUE}"
    export DEPLOY_TAG="latest"
elif [ "$ENVIRONMENT" == "andino-dev" ]; then
    echo "Ambiente $ENVIRONMENT"

    export USE_VPN="1"

    export DEPLOY_TARGET_SSH_PORT="$ANDINO_DEV_DEPLOY_TARGET_SSH_PORT"
    export DEPLOY_TARGET_USERNAME="$ANDINO_DEV_DEPLOY_TARGET_USERNAME"
    export DEPLOY_TARGET_IP="$ANDINO_DEV_DEPLOY_TARGET_IP"
    export DEPLOY_ENVIRONMENT="$ENVIRONMENT"
    export MTU_VALUE="${ANDINO_DEV_MTU_VALUE:-DEFAULT_MTU_VALUE}"
    export DEPLOY_TAG="latest"
else
    echo "Ambiente '$ENVIRONMENT' desconocido";
    exit 1;
fi
