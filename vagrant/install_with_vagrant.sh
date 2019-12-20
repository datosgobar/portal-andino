#!/bin/bash
set -e


echo -n "Ingresá en qué distribución de Linux querés probar Andino (ubuntu | debian | rhel | centos): "
read DISTRO

case $DISTRO in

  "ubuntu" | "Ubuntu" | "UBUNTU")
    DISTRO=ubuntu
    ;;

  "debian" | "Debian" | "DEBIAN")
    DISTRO=debian
    ;;

  "rhel" | "Rhel" | "RHEL")
    DISTRO=rhel
    if ! [ -s rhel/.env ] ;
    then
        echo "Se requiere un archivo \".env\" en el directorio \"rhel/\" donde se especifiquen las" \
        "credenciales de un usuario de RHEL de la siguiente manera:"
        echo "user=un_nombre_de_usuario"
        echo "password=una_contraseña"
        exit 1
    else
        echo "Leyendo las credenciales del usuario de RHEL..."
    fi

    source ./rhel/.env
    if [ -z $user ] || [ -z $password ];
    then
        echo "Usuario y contraseña mal seteados."
        exit 1
    else
        echo "Datos encontrados."
    fi
    ;;

  "centos" | "CentOS" | "CENTOS")
    DISTRO=centos
    ;;

  *)
    echo "No se ingresó una de las distribuciones mencionadas."
    exit 1
    ;;
esac

cd $DISTRO
vagrant up
echo "Mostrando status de vagrant"
echo "$(vagrant status)"
echo "Corriendo los tests post-actualización"
vagrant ssh -c "sudo nosetests portal-andino/tests/configurations/ portal-andino/tests/globals/" andino_${DISTRO}
echo "Los tests corrieron exitosamente!"
