Portal Andino
------------
El `Portal andino` es una implementacion de CKAN utilizando un conjunto de tecnologias que mejoran considerablemnte la estabilidad y perfomance del mismo.
La implementacion en la presente version utiliza tres contendores padres para conformar la plataforma, siendo los mismo:
+ APP-CKAN:
	+ Packages | Service:
		+ Imagen base: ubuntu xenial 16.04
		+ NGINX
		+ Apache 2 | WSGI MOD
		+ CKAN 2.5.2
		+ Supervisor
		+ Postfix
		+ RabbitMQ
	+ Plugins:
		+ DataStore
		+ FileStore
		+ Datapusher
		+ DataJSONAR
		+ Andino Theme
		+ Harvest
		+ Hierarchy
+ PG-CKAN:
	+ Packages | Service:
		+ PostgreSQL 9.5
+ SOLR-CKAN:
	+ Package | Service
		+ Solr 6.0
	+ Plugins:
		+ CKAN_Schema 2.2+(Hierarchy-Mig)
	

+ [Que es CKAN?](#que-es-ckan)
+ [Que contiene Andino](#features)
+ [Prerequisitos](#prerequisitos)
    + [DOCKER](#docker)
    + [GIT TOOLs](#git-tools)
+ [Instalacion y Ejecucion de Andino](#instalación)
	+ [Dependencias de la instalación de Andino](#dependencias)
    + [Instalacion Simplificada de Andino](#instalacion-simplificada-de-andino)
    + [Instalacion Avanzada de Andino](#instalacion-avanzada-building-andino)
+ [Usage](#usage)
	+ [Crear usuario Admin para Andino](#crear-usuario-administrador-para-andino)
	+ [Configurar la URL de Andino](#configurar-url-de-andino)
+ [Credits | Copying](#credits--copying)
+ [Contacto](#contacto)	
+ [Consultas o dudas?](#comentarios-preguntas)

Features:
---
+ [CKAN 2.5.2](http://docs.ckan.org/en/ckan-2.5.2/)
+ [Datastore](http://docs.ckan.org/en/latest/maintaining/datastore.html)
+ [FileStore](http://docs.ckan.org/en/latest/maintaining/filestore.html)
+ [Datapusher](https://github.com/ckan/datapusher)
+ [Hierarchy](https://github.com/datagovuk/ckanext-hierarchy)
+ [datajsonAR](https://github.com/datosgobar/ckanext-datajsonAR)
+ [Harvest](https://github.com/ckan/ckanext-harvest)
+ [Portal Andino theme](https://github.com/gobabiertoAR/portal-andino-theme/blob/master/docs/03_instalacion_tema_visual.md)
+ [Apache2 & NginX](http://docs.ckan.org/en/ckan-2.5.2/maintaining/installing/deployment.html#install-apache-modwsgi-modrpaf)

Instalación
-----------
_En funcion a la probable dificultad de implementacion e incluso, la cantidad de pasos a realizar para lograr un deploy existoso, existen dos formas de instalar esta distribución de **CKAN**. Si no tenes muchos conocimientos de CKAN, Docker o de administracion de servidores en general, muy posiblemente, deberias utilizar la instalacion **[Simplificada  de Andino](#instalacion-simplificada-de-andino)**, la cual, esta pensada para que en la menor cantidad de pasos y de manera sencilla, tengas un Portal de Datos Funciona (Y muy bello :D). Ahora si por ejemplo, ya conoces la plataforma, tenes experiencia con Docker o simplemente, queres entender como es que funciona esta implementacion, te sugiero que revises la **[Instalacion Avanzada de Andino](#instalacion-avanzada-de-andino)**_

Dependencias:
---
+ ##### DOCKER: [Guia de instalacion](https://docs.docker.com/engine/installation).
+ ##### GIT-CORE:[Guia de instalacion](https://desktop.github.com)


Instalacion Simplificada de `Andino`:
---
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

#### Instalacion Avanzada, building `Andino`:
La Instalacion Avanzada esta pensada para aquellos usuarios que desean quizas, un poco mas como funciona intenamente `Andino`
_Para instalar y ejecutar Andino, debemos seguir los siguientes pasos:_

+ Paso 1: Clonar Repositorio. 
_Es recomendable clonar el repo dentro de /tmp (o C:\temp en **Windows X**), dado que al finalizar la instalacion, no usaremos mas el repositorio_.
		
		$ cd /tmp # en Linux, en Windows, usar cd C:\temp
		$ git clone https://github.com/datosgobar/portal-andino.git

+ Paso 2: _construir y lanzar el contenedor de **pg-ckan** usando el Dockerfile hubicado en `postgresql-img/`._ 

		$ cd /tmp/ckan_in_docker/postgresql-img/
		$ docker build -t datosgobar/pg-ckan:latest . && docker run -d --name pg-ckan datosgobar/pg-ckan:latest


+ Paso 3: _construir y lanzar el contenedor de **solr-ckan** usando el Dockerfile hubicado en `solr-img/`._

		$ cd /tmp/ckan_in_docker/solr-img/ 
		$ docker build -t datosgobar/solr-ckan:latest . && docker run -d  --name solr-ckan datosgobar/solr-ckan:latest

+ Paso 4: _construir el contenedor de **app-ckan** usando el Dockerfile hubicado en `ckan-img/`._

		$ cd /tmp/ckan_in_a_box/ckan-img
		$ docker build -t datosgobar/app-ckan:latest .

+ Paso 5: _Correr contenedor  de **Andino**_
		
		$ docker run -d --link pg-ckan:db --link solr-ckan:solr -p 80:80 -p 8800:8800 --name app-ckan datosgobar/ckan-distribuilble:latest

Usage:
-----
Una vez finalizada la instalacion, cualquiera fuere el metodo utilizado, deberiamos realizar las siguientes tareas:

#### Crear usuario administrador para Andino:
	
```bash		
#
# Asumo que el contenedor de ckan es llamado al ser lanzado "app-ckan"
# Entrar al contenedor de Andino
$ docker exec -it app-ckan /bin/bash
#
# Crear usuario ckan_admin:
$ $CKAN_HOME/bin/paster --plugin=ckan sysadmin add ckan_admin -c /etc/ckan/default/production.ini
```

#### Configurar url de Andino:
```bash
#
# Asumo que el contenedor de ckan es llamado al ser lanzado "app-ckan"
# Entrar al contenedor de Andino:
$ docker exec -it app-ckan /bin/bash
#
# 
# Cambiar "tu-domino" y "ip-del-server" por los valores que corresponda.
$CKAN_HOME/bin/paster --plugin=ckan \
	config-tool /etc/ckan/default/production.ini -e \
	"ckan.site_url = http://tu-dominio.com.ar" \
	"ckan.datapusher.url = http://ip-del-server.com.ar:8800"
```

Credits | Copying
---
Este trabajo esta inspirado en el desarrollo realizado por:

+ [CKAN.org](https://github.com/ckan/ckan/)
+ [Eccenca](https://github.com/eccenca/ckan-docker)

Contacto:
---
Este proyecto es en desarrollo, si viste algun `bug`, por favor, [creanos un issue](https://github.com/datosgobar/portal-andino/issues/new?title=Encontre un bug en Adino).

Tenes comentarios o preguntas?
---
Escribinos a [datos@modernizacion.gob.ar](mailto:datos@modernizacion.gob.ar)
