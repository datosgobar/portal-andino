# Generación de imágenes Docker

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Generación de imágenes Docker](#generacion-de-imagenes-docker)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Para generar las imágenes, ejecutar la aplicación y levantarla, previamente es necesario instalar `Docker` y `docker-compose`:

* Instalar [Docker](https://docs.docker.com/engine/installation/linux/ubuntu/)
* Instalar [docker-compose](https://docs.docker.com/compose/install/)

Actualmente, el repositorio contiene 1 arhivo `Dockerfile` y 2 archivos `docker-compose`

* `Dockerfile`: Se usa para generar la imagen de la aplicación
* `dev.yml`: Archivo de docker-compose para levantar los servicios necesarios y generar la imagen de la aplicación.
* `latest.yml`: Archivo de docker-compose para levantar la aplicación a su última version. (ver [instalación](install.md))

Para levantar toda la aplicacion, se puede correr:

    $ docker-compose -f dev.yml up -d nginx
    
Si es la primera vez que se corre este comando, puede llegar a tardar bastante en descargar las imágenes.
Una vez terminado, dejar en el puerto `localhost:80` la aplicacion ejecutándose, pero antes se debe correr un comando para inicializar el desarrollo:

    $ docker exec -it andino /etc/ckan_init.d/init_dev.sh


También se pueden levantar los servicios por separado de la aplicación:

* Los `servicios`:

```$ docker-compose -f dev.yml up --build --abort-on-container-exit db sol redis postfix```

* La aplicación andino que tendrá el puerto `8080` y en el `8800` el datapusher.
    
```$ docker-compose -f dev.yml up --abort-on-container-exit --build --no-deps portal```

* Nginx que estará en el puerto `80`:
    
```$ docker-compose -f dev.yml up -d --no-deps nginx```

Eso levantará la aplicación con el directorio actual (`$PWD`) disponible dentro del directorio `/dev-app` del container.

Para acceder a la aplicación, hacer modificaciones en `runtime`, basta con correr el comando:

    $ docker-compose -f dev.yml exec andino /bin/bash
