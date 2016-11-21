Portal Andino
------------
## Que es CKAN?
Comprehensive Knowledge Archive Network (CKAN) es una aplicación web de código abierto para el almacenamiento y la distribución de los datos, tales como hojas de cálculo y los contenidos de las bases de datos. Está inspirado en las capacidades de gestión de paquetes comunes para abrir sistemas operativos, como Linux, y está destinado a ser el "apt-get de Debian para los datos". _Fuente: [wikipedia](https://es.wikipedia.org/wiki/CKAN)_

_...Mas informacion sobre CKAN?... Obvio! [Documentacion Oficial de CKAN](http://docs.ckan.org/en/latest/)_

## Que es Andino?
Descripcion de Andino....

Indice:
------
+ [Que es CKAN?](#que-es-ckan)
+ [Que es Andino?](que-es-andino)
+ [Que contiene Andino](#features)
+ [Prerequisitos](#prerequisitos)
    + [DOCKER](#docker)
    + [GIT TOOLs](#git-tools)
+ [Instalacion y Ejecucion de Andino](#instalación)
	+ [Pre requisitos para la instalacion de Andino](#prerequisitos)
    + [Instalacion Simplificada de Andino](#instalacion-simplificada-de-ckan)
    + [Instalacion Avanzada de Andino](#instalacion-avanzada-de-ckan)
+ [Usage](#usage)
+ [Credits | Copying](#credits--copying)
+ [Contacto](#contacto)	
+ [Consultas o dudas?](#comentarios-preguntas)


---




Instalación
-----------
#### Prerequisitos:

+ **DOCKER**:

	Docker es un proyecto de código abierto que automatiza el despliegue de aplicaciones dentro de contenedores de software, proporcionando una capa adicional de abstracción y automatización de Virtualización a nivel de sistema operativo en Linux. _Fuente: [wikipedia](https://es.wikipedia.org/wiki/Docker_(software))_

	_...Deseas saber mas sobre docker? Genial! Docker posee una documentacion excelente y podes verla [aqui](https://docs.docker.com/)_

	#### Instalacion:

	+ Docker para Debian | Ubuntu | RHEL | CentOS

			sudo curl -sSL http://get.docker.com | sh

	+ Docker para [OSX](https://docs.docker.com/docker-for-mac).
	+ Docker para [Windows](https://docs.docker.com/engine/installation/windows).


+ **GIT-CORE TOOLS**:

	GitHub es una forja (plataforma de desarrollo colaborativo) para alojar proyectos utilizando el sistema de control de versiones Git. Utiliza el framework Ruby on Rails por GitHub, Inc. (anteriormente conocida como Logical Awesome). Desde enero de 2010, GitHub opera bajo el nombre de GitHub, Inc. El código se almacena de forma pública, aunque también se puede hacer de forma privada, creando una cuenta de pago._Fuente: [wikipedia](https://es.wikipedia.org/wiki/GitHub)_

	#### Instalacion:

	+ Windows:(_Descargar e Instalar desde_)
	
			https://github.com/git-for-windows/git/releases/tag/v2.10.0.windows.1

	+ Ubuntu/Debian:

			$ sudo apt-get -y install git-core"

	+ RHEL/CentOS:

			$ yum install -y git-core

	+ OSX:

		    $ sudo port install git-core +svn +doc +bash_completion +gitweb


Instalacion y Ejecucion de Andino
-------------------------------
_En funcion a la probable dificultad de implementacion e incluso, la cantidad de pasos a realizar para lograr un deploy existoso, existen dos formas de instalar esta distribución de **CKAN**. Si no tenes muchos conocimientos de CKAN, Docker o de administracion de servidores en general, muy posiblemente, deberias utilizar la instalacion **[Simplificada  de CKAN](#instalacion-simplificada-de-ckan)**, la cual, esta pensada para que en la menor cantidad de pasos y de manera sencilla, tengas un Portal de Datos Funciona (Y muy bello :D). Ahora si por ejemplo, ya conoces la plataforma, tenes experiencia con Docker o simplemente, queres entender como es que funciona esta implementacion, te sugiero que revises la **[Instalacion Avanzada de CKAN](#instalacion-avanzada-de-ckan)**_


#### Instalacion Simplificada de `Andino`:

_La idea detras de esta implementacion de CKAN, es que **SOLO** te encargues de tus datos, nada mas, por tanto, si "copias y pegas" el comando de consola, en solo unos momentos, tendras un Andino listo para usar._
_Esta clase de instalacion no requiere que clones el repositorio, dado que usaremos contenedores alojados en [DockerHub](https://hub.docker.com/r/datosgobar)

+ Ubuntu|Debian|RHEL|CentOS:

	```bash
	# No tenes Docker? no importa:
	# Instalacion de Docker:
	# =====================
	#
	# 	sudo su -c "curl -sSL http://get.docker.com | sh"
	#
	$ docker run -d --name pg-ckan datosgobar/pg-ckan:latest && docker run -d --name solr-ckan datosgobar/solr-ckan:latest && docker run -d --name  app-ckan -p 80:80 -p 8800:8800 --link pg-ckan:db --link solr-ckan:solr datosgobar/app-ckan:latest
	```
---

#### Instalacion Avanzada de CKAN, build `Andino`:

_Para instalar y ejecutar CKAN-Docker, debemos seguir los siguientes pasos:_

+ Paso 1: Clonar Repositorio. 
_Es recomendable clonar el repo dentro de /tmp (o C:\temp en **Windows X**), dado que al finalizar la instalacion, no usaremos mas el repositorio_.
		
		$ cd /tmp # en Linux, en Windows, usar cd C:\temp
		$ git clone https://github.com/datosgobar/portal-andino.git

+ Paso 2: _construir y lanzar el contenedor de **PostgreSQL** usando el Dockerfile hubicado en `postgresql-img/`._ 

		$ cd /tmp/ckan_in_docker/postgresql-img/
		$ docker build -t datosgobar/pg-ckan:latest . && docker run -d --name pg-ckan datosgobar/pg-ckan:latest


+ Paso 3: _construir y lanzar el contenedor de **Solr** usando el Dockerfile hubicado en `solr-img/`._

		$ cd /tmp/ckan_in_docker/solr-img/ 
		$ docker build -t datosgobar/solr-ckan:latest . && docker run -d  --name solr-ckan datosgobar/solr-ckan:latest

+ Paso 4: _construir el contenedor de **app-ckan** usando el Dockerfile hubicado en `ckan-img/`._

		$ cd /tmp/ckan_in_a_box/ckan-img
		$ docker build -t datosgobar/app-ckan:latest .

+ Paso 5: _Correr contenedor  de **CKAN**_
		
		$ docker run -d --link pg-ckan:db --link solr-ckan:solr -p 80:80 -p 8800:8800 --name app-ckan datosgobar/ckan-distribuilble:latest

USAGE:
-----
+ Paso 6(Opcional): _Crear usuario administrador **ckan_admin**_
	```bash		
	# Add USER ADMIN
	$ docker exec -it ckan-distribuilble /bin/bash -c "$CKAN_HOME/bin/paster --plugin=ckan sysadmin add ckan_admin -c /etc/ckan/default/production.ini"
	# ---
	# BIND CKAN
	$ docker exec -it ckan-distribuilble /bin/bash -c "$CKAN_HOME/bin/paster --plugin=ckan config-tool /etc/ckan/default/production.ini -e 'ckan.site_url = http://tu_dominio.com.ar' 'ckan.datapusher.url = http://tu_dominio.com.ar:8800'"
	```

CREDITS | COPYING
---
Este trabajo esta inspirado en el desarrollo realizado por [CKAN.org](https://github.com/ckan/ckan/)

CONTACTO:
---
Este proyecto es en desarrollo, si viste algun `bug`, por favor, [creanos un issue](https://github.com/datosgobar/portal-andino/issues/new?title=Encontre un bug en Adino).

COMENTARIOS?, PREGUNTAS?
---
Escribinos a [datos@modernizacion.gob.ar](mailto:datos@modernizacion.gob.ar)