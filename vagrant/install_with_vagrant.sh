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
