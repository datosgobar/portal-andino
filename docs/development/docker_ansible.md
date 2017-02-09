# Docker y Ansible

Para generar las imágenes levantar la aplicación y levantarla, es necesario instalar `Docker` y `docker-compose`:

* Instalar [Docker](https://docs.docker.com/engine/installation/linux/ubuntu/)
* Instalar [docker-compose](https://docs.docker.com/compose/install/)

### Docker
Actualmente el repositorio contiene 3 arhivos `Dockerfile` y un archivo `docker-compose`

```
    ckan-img/Dockerfile
    postgresql-img/Dockerfile
    solr-img/Dockerfile
    dev.yml
```

Luego se corre el siguiente comando:

    $ docker-compose -f dev.yml up --abort-on-container-exit andino
    
Si es la primera vez que se corre este comando, puede llegar a tardar bastante en generar la imagen para andino.
Una vez terminado, esto dejarar en el puerto localhost:80 la aplicacion corriendo.

Para desarrollo, pueden correrse los `servicios` por separado:

    $ docker-compose -f dev.yml up --build --abort-on-container-exit db sol

Luego la aplicación con los archivos disponibles:
    
    $ docker-compose -f dev.yml up --abort-on-container-exit --no-deps andino
    
Eso levantará la aplicación con el directorio actual (`$PWD`) disponible dentro del directorio `/dev-app` del container.

Para acceder a la aplicación, hacer modificaciones en `runtime`, basta con correr el comando:

    $ docker-compose -f dev.yml exec andino /bin/bash


### Ansible

La imagen para la aplicación andino instala y configura [ckan](https://ckan.org/) con algunos plugins y modificaciones.
Para provisionar la imagen con estas dependencias, se usa [ansible](https://www.ansible.com/).
