# Docker en Ubuntu/Debian

Documentacion creada y testeada en **Trusty Tahr 14.04 de Ubuntu** y **Jessie 8.0 de Debian**.



### Paso 1 UPDATE & UPGRADE
	sudo apt-get update && sudo apt-get -y upgrade

### Nos aserguramos tenemos soporte para aufs disponible:
	sudo apt-get -q -y install linux-image-extra-`uname -r`

### KEY para el repositorio de Docker.io:
	sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

### Añadimos el repositorio de Docker a APT Sources:
	echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
	echo "deb http://cz.archive.ubuntu.com/ubuntu trusty main" | sudo tee /etc/apt/sources.list
	sudo apt-get update && sudo apt-get -y upgrade

### Update apt-get e install docker-engine:
	sudo apt-get install docker-engine
	sudo service docker start

### Editamos la configuracion de UFW:
	sudo sed 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw > /etc/default/ufw.tmp && mv /etc/default/ufw.tmp /etc/default/ufw

### Recargamos el servicio ufw:
	sudo ufw reload

### Correr Docker como Daemon
	sudo docker -d &

### Correr $ Docker sin "sudo"
	sudo groupadd docker
	sudo gpasswd -a ${USER} docker
	sudo service docker restart
	
_Para mas informacion sobre estas distros de linux, por favor, visitar: [Ubuntu Trusty](http://releases.ubuntu.com/14.04/) y [Debian Jessie](https://www.debian.org/News/2015/20150426)_

_Para conocer el proceso de instalacion en otras distros de Debian y/o Ubuntu o saber mas del proyecto **Docker**, por favor, viste el sitio Oficial de [Docker](http://docker.io)