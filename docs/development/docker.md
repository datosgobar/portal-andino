# Docker y Ansible

Para generar las imágenes levantar la aplicación y levantarla, es necesario instalar `Docker` y `docker-compose`:

* Instalar [Docker](https://docs.docker.com/engine/installation/linux/ubuntu/)
* Instalar [docker-compose](https://docs.docker.com/compose/install/)

### Docker
Actualmente el repositorio contiene 1 arhivo `Dockerfile` y 1 archivos `docker-compose`

Para levantar toda la aplicacion, se puede correr:

    $ docker-compose -f dev.yml up -d nginx
    
Si es la primera vez que se corre este comando, puede llegar a tardar bastante en generar la imagen para andino.
Una vez terminado, esto dejarar en el puerto localhost:80 la aplicacion corriendo.


Para desarrollo, pueden correrse los `servicios` por separado:

    $ docker-compose -f dev.yml up --build --abort-on-container-exit db sol redis postfix

Luego la aplicación andino/ckan disponibles que estara en el puerto `8800` para el `Datapusher`:
    
    $ docker-compose -f dev.yml up --abort-on-container-exit --no-deps andino

Y luego nginx que estara en el puerto `80`:
    
    $ docker-compose -f dev.yml up -d --no-deps nginx

Eso levantará la aplicación con el directorio actual (`$PWD`) disponible dentro del directorio `/dev-app` del container.


Para inicializar en desarrollo:

    $ docker exec -it andino /etc/ckan_init.d/init_dev.sh

Para acceder a la aplicación, hacer modificaciones en `runtime`, basta con correr el comando:

    $ docker-compose -f dev.yml exec andino /bin/bash


