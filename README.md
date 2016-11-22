# Portal Andino

Implementación de CKAN en Docker, desarrollada en el contexto del portal distribuible Andino. 
También podés [ver el repositorio del tema visual](https://github.com/datosgobar/portal-andino-theme).

## Índice
+ [Qué contiene el paquete de Andino](#qué-contiene-el-paquete-de-andino)
+ [Instalación](#instalación)
	+ [Dependencias](#dependencias)
    + [Instalación simplificada](#instalación-simplificada)
    + [Instalación avanzada](#instalación-avanzada)
+ [Uso](#uso)
	+ [Crear usuario administrador](#crear-usuario-administrador)
	+ [Configurar URL de Andino](#configurar-url-de-andino)
+ [Créditos](#créditos)
+ [Contacto](#contacto)	

## Qué contiene el paquete de Andino

+ [CKAN 2.5.2](http://docs.ckan.org/en/ckan-2.5.2/)
+ [Datastore](http://docs.ckan.org/en/latest/maintaining/datastore.html)
+ [FileStore](http://docs.ckan.org/en/latest/maintaining/filestore.html)
+ [Datapusher](https://github.com/ckan/datapusher)
+ [Hierarchy](https://github.com/datagovuk/ckanext-hierarchy)
+ [datajsonAR](https://github.com/datosgobar/ckanext-datajsonAR)
+ [Harvest](https://github.com/ckan/ckanext-harvest)
+ [Portal Andino theme](https://github.com/datosgobar/portal-andino-theme)
+ [Apache2 & NginX](http://docs.ckan.org/en/ckan-2.5.2/maintaining/installing/deployment.html#install-apache-modwsgi-modrpaf)

## Instalación

Teniendo en cuenta la dificultad de implementacion e incluso la cantidad de pasos para lograr un deploy existoso, existen dos formas de instalar esta distribución de **CKAN**. 

- Si no tenés muchos conocimientos de CKAN, Docker o de administracion de servidores en general, es recomendable usar la instalación **[simplificada  de Andino](#instalacion-simplificada-de-andino)**. Está pensada para que en la menor cantidad de pasos y de manera sencilla, tengas un portal de datos funcionando. 
- Si ya conocés la plataforma, tenés experiencia con Docker o simplemente, querés entender cómo funciona esta implementación, te sugiero que revises la **[instalacion avanzada de Andino](#instalacion-avanzada-de-andino)**

### Dependencias

+ DOCKER: [Guía de instalación](https://docs.docker.com/engine/installation).
+ GIT: [Guía de instalación](https://desktop.github.com)

#### Instalación simplificada

La idea detrás de esta implementación de CKAN es **que sólo te encargues de tus datos**, nada más. Por eso, si "copiás y pegás" el comando de consola, en sólo unos momentos, tendrás un Andino listo para usar.
Esta clase de instalación no requiere que clones el repositorio, ya que usamos contenedores alojados en [DockerHub](https://hub.docker.com/r/datosgobar)

+ Ubuntu|Debian|RHEL|CentOS:

	```bash
	# ¿No tenes Docker? No importa:
	# Instalación de Docker:
	# =====================
	#
	# 	sudo su -c "curl -sSL http://get.docker.com | sh"
	#
	$ docker run -d --name pg-ckan datosgobar/pg-ckan:latest && docker run -d --name solr-ckan datosgobar/solr-ckan:latest && docker run -d --name  app-ckan -p 80:80 -p 8800:8800 --link pg-ckan:db --link solr-ckan:solr datosgobar/app-ckan:latest
```
##### ¿Qué contenedores vas a instalar?

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

---

#### Instalación avanzada

La instalación avanzada está pensada para usarios que quieren ver cómo funciona internamente `Andino`

Para instalar y ejecutar Andino, seguimos estos pasos:

+ Paso 1: Clonar repositorio. 
_Es recomendable clonar el repo dentro de /tmp (o C:\temp en **Windows X**), ya que al finalizar la instalación, no usaremos más el repositorio_.
		
		$ cd /tmp # en Linux, en Windows, usar cd C:\temp
		$ git clone https://github.com/datosgobar/portal-andino.git

+ Paso 2: _construir y lanzar el contenedor de **pg-ckan** usando el Dockerfile ubicado en `postgresql-img/`._ 

		$ cd /tmp/ckan_in_docker/postgresql-img/
		$ docker build -t datosgobar/pg-ckan:latest . && docker run -d --name pg-ckan datosgobar/pg-ckan:latest


+ Paso 3: _construir y lanzar el contenedor de **solr-ckan** usando el Dockerfile ubicado en `solr-img/`._

		$ cd /tmp/ckan_in_docker/solr-img/ 
		$ docker build -t datosgobar/solr-ckan:latest . && docker run -d  --name solr-ckan datosgobar/solr-ckan:latest

+ Paso 4: _construir el contenedor de **app-ckan** usando el Dockerfile ubicado en `ckan-img/`._

		$ cd /tmp/ckan_in_a_box/ckan-img
		$ docker build -t datosgobar/app-ckan:latest .

+ Paso 5: _Correr contenedor  de **Andino**_
		
		$ docker run -d --link pg-ckan:db --link solr-ckan:solr -p 80:80 -p 8800:8800 --name app-ckan datosgobar/ckan-distribuilble:latest

## Uso

Una vez finalizada la instalación, bajo cualquiera de los métodos, deberíamos:

### Crear usuario administrador
	
```bash		
#
# Asumo que el contenedor de ckan es llamado al ser lanzado "app-ckan"
# Entrar al contenedor de Andino
$ docker exec -it app-ckan /bin/bash
#
# Crear usuario ckan_admin:
$ $CKAN_HOME/bin/paster --plugin=ckan sysadmin add ckan_admin -c /etc/ckan/default/production.ini
```

### Configurar url de Andino
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

## Créditos

Este trabajo está inspirado en el desarrollo hecho por:

+ [CKAN.org](https://github.com/ckan/ckan/)
+ [Eccenca](https://github.com/eccenca/ckan-docker)

## Contacto

Te invitamos a [crearnos un issue](https://github.com/datosgobar/portal-andino/issues/new?title=Encontre un bug en nombre-del-repo) en caso de que encuentres algún bug o tengas feedback de alguna parte de `portal-andino`.

Para todo lo demás, podés mandarnos tu comentario o consulta a [datos@modernizacion.gob.ar](mailto:datos@modernizacion.gob.ar).
