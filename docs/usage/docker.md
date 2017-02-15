# Instalación con Docker (WIP)

### Esta guía instala la última version _en desarrollo_ de andino, puede contener bugs o no funcionar

Esta clase de instalación no requiere que clones el repositorio, ya que usamos contenedores alojados en [DockerHub](https://hub.docker.com/r/datosgobar)

### Ubuntu

+ Requerimientos:
    - Docker: `sudo su -c "curl -sSL http://get.docker.com | sh"`

+ Instalación:
  * Pull de imágenes

    ```
    $ docker pull datosgobar/andino-psql && \
        docker pull datosgobar/portal-andino:development-solr && \
        docker pull redis:3.2.7-alpine && \
        docker pull rabbitmq:3.6.6-alpine && \
        docker pull catatnight/postfix && \
        docker pull datosgobar/portal-andino:development-andino && \
        docker pull datosgobar/portal-andino:development-nginx
    ```
  * Crear containers:

    ```
    $ docker run -d --name andino-psql datosgobar/portal-andino:development-psql && \
        docker run -d --name andino-solr datosgobar/portal-andino:development-solr && \
        docker run -d --name andino-redis redis:3.2.7-alpine && \
        docker run -d --name andino-rabbitmq -h rabbitmq rabbitmq:3.6.6-alpine && \
        docker run -d --name andino-postfix -p 25:25 -p 587:587 catatnight/postfix && \
        docker run -d --name andino -p 8800:8800 \
            --link andino-psql:db --link andino-solr:solr \
            --link andino-redis:redis --link andino-rabbitmq:rabbitmq \
            --link andino-postfix:postfix \
            datosgobar/portal-andino:development-andino && \
        docker run -d --name andino-nginx -p 80:80 --link andino:andino datosgobar/portal-andino:development-nginx
    ```
