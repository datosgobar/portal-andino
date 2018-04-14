#!/usr/bin/env bash

set -e;

# Nota: Las variables no definidas aqui deben ser seteadas en ./variables.sh
# si tenes dudas sobre la sintaxis ${!variable}, mira https://stackoverflow.com/a/1921337/2355756
# files.tar.gz.enc debe ser un archivo encriptado por el cliente de travis con la siguiente estructura:
# .
# └── files
#     ├── andino-dev
#     │   ├── client.ovpn
#     │   └── deployment@travis-ci.org
#     └── datosgobar-dev
#         ├── client.ovpn
#         └── deployment@travis-ci.org
# 
# donde `andino-dev` y `datosgobar-dev` son los distintos ambientes, `client.ovpn` es el túnel de la vpn
# y `deployment@travis-ci.org` la key privada SSH del usuario de deploy.
# Este método está ligeramente basado en https://oncletom.io/2016/travis-ssh-deploy/

export files_key_var_name="encrypted_4c1767ebb72f_key"
export files_iv_var_name="encrypted_4c1767ebb72f_iv"

deploy_files="scripts/deploy"
files_tar="$deploy_files/files.tar.gz"
enc_files_tar="$deploy_files/files.tar.gz.enc"

# desencriptar
echo "Desencriptando"
openssl aes-256-cbc -K ${!files_key_var_name} -iv ${!files_iv_var_name} -in $enc_files_tar -out $files_tar -d

echo "Descomprimiendo"
tar zxvf $files_tar -C $deploy_files

environment_files="$deploy_files/files/$DEPLOY_ENVIRONMENT"

echo "Inicializando acceso ssh"
# Desencripto la key ssh para acceder al server
cp "$environment_files/deployment@travis-ci.org" /tmp/deployment@travis-ci.org
chmod 600 /tmp/deployment@travis-ci.org

if [ -n "$USE_VPN" ]; then
    echo "Conectando a la VPN";
    sudo cp "$environment_files/client.ovpn" "$OVPN_PATH"
    sudo service openvpn restart
    echo "Esperando..."
    sleep 10
    echo "Verificando VPN..."
    ifconfig -a | sed 's/[ \t].*//;/^$/d'
    ifconfig | grep -oh tun0
fi

echo "Seteo valor de mtu"
sudo ifconfig tun0 mtu $MTU_VALUE

echo "Inicializando known_hosts"
# Agrego el host a known_hosts
ssh-keyscan -p $DEPLOY_TARGET_SSH_PORT -t 'rsa,dsa,ecdsa' -H $DEPLOY_TARGET_IP 2>&1 | tee -a $HOME/.ssh/known_hosts
