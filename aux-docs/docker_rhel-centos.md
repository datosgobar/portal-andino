# Docker en RHEL/CentOS:

---

## Paso 1: update a Yum.
	
	$ sudo yum update

## Paso 2: Añadir el Repositorio de Docker.
	$ sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
	[dockerrepo]
	name=Docker Repository
	baseurl=https://yum.dockerproject.org/repo/main/centos/7/
	enabled=1
	gpgcheck=1
	gpgkey=https://yum.dockerproject.org/gpg
	EOF


## Paso 3: Instalar paquetes de Docker:

	$ sudo yum install docker-engine

## Paso 4: Instalar e iniciar el Daemon de Docker.

	$ sudo chkconfig docker on
	$ sudo service docker start

## Paso 5: Verificar que Docker fue correctamente instalado:

	$ sudo docker run hello-world

_Deberias ver la siguiente salida:_

```bash
Unable to find image 'hello-world:latest' locally
    latest: Pulling from hello-world
    a8219747be10: Pull complete
    91c95931e552: Already exists
    hello-world:latest: The image you are pulling has been verified. Important: image verification is a tech preview feature and should not be relied on to provide security.
    Digest: sha256:aa03e5d0d5553b4c3473e89c8619cf79df368babd1.7.1cf5daeb82aab55838d
    Status: Downloaded newer image for hello-world:latest
    Hello from Docker.
    This message shows that your installation appears to be working correctly.

    To generate this message, Docker took the following steps:
     1. The Docker client contacted the Docker daemon.
     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
            (Assuming it was not already locally available.)
     3. The Docker daemon created a new container from that image which runs the
            executable that produces the output you are currently reading.
     4. The Docker daemon streamed that output to the Docker client, which sent it
            to your terminal.

    To try something more ambitious, you can run an Ubuntu container with:
     $ docker run -it ubuntu bash

    For more examples and ideas, visit:
     http://docs.docker.com/userguide/
```
## Usar docker sin "sudo"

### Paso 6: Crear grupo "docker"
	
	$ sudo groupadd docker

### Paso 7: añadir tu usuario al grupo antes creado.

	$ sudo usermod -aG docker your_username

### Paso 8: Chequear que todo funciona perfectamente: 
	
 	$ docker run hello-world

 _deberia ver la misma salida que en **Paso 5**_

 _Para mas informacion sobre estas distros de linux, por favor, visitar: [RHEL 7](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/7.0_Release_Notes/) y [CentOS 7](https://wiki.centos.org/)_

 _Para conocer el proceso de instalacion en otras distros de RHEL y/o CentOS o saber mas del proyecto **Docker**, por favor, viste el sitio Oficial de [Docker](http://docker.io)_