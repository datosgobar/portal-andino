# Portal Andino

## Instalación

Teniendo en cuenta la dificultad de implementacion e incluso la cantidad de pasos para lograr un deploy existoso, existen dos formas de instalar esta distribución de **CKAN**. 

- Si no tenés muchos conocimientos de CKAN, Docker o de administracion de servidores en general, es recomendable usar la instalación **[simplificada  de Andino](#instalacion-simplificada-de-andino)**. Está pensada para que en la menor cantidad de pasos y de manera sencilla, tengas un portal de datos funcionando. 
- Si ya conocés la plataforma, tenés experiencia con Docker o simplemente, querés entender cómo funciona esta implementación, te sugiero que revises la **[instalacion avanzada de Andino](#instalacion-avanzada-de-andino)**

### Dependencias

+ DOCKER: [Guía de instalación](https://docs.docker.com/engine/installation).
+ Docker Compose: [Guía de instalación](https://docs.docker.com/compose/install/)

### Instalación simplificada

La idea detrás de esta implementación de CKAN es **que sólo te encargues de tus datos**, nada más. Por eso, si "copiás y pegás" el comando de consola, en sólo unos momentos, tendrás un Andino listo para usar.
Esta clase de instalación no requiere que clones el repositorio, ya que usamos contenedores alojados en [DockerHub](https://hub.docker.com/r/datosgobar)

+ Ubuntu|Debian|RHEL|CentOS:

+ Instalación:

Para esta instalación ciertos parametros deben ser pasados a la aplicacion:

+ Email donde se mandarán los errores. `EMAIL=admin@example.com`
+ Dominio o IP de la aplicación: `HOST=datos.gob.ar`
+ Usuario de la base de datos: `DB_USER=<my db user>`
+ Password de la base de datos: `DB_PASS=<my db pass>`
+ Usuario del datastore: `STORE_USER=<my datastore user>`
+ Password del datastore: `STORE_PASS=<my datastore password>`

```bash
# Primero seleccionamos lo valores necesarios
EMAIL=admin@example.com
HOST=http://192.168.35.10/
DB_USER=my_database_user
DB_PASS=my_database_pass
STORE_USER=my_data_user
STORE_PASS=my_data_pass

# Descargamos el script de instalacion python
wget https://raw.github.com/datosgobar/portal-andino/master/install/install.py

# Corremos el script de instalacion
sudo -E python ./install.py --error_email "$EMAIL" --site_host="$HOST" \
    --database_user="$DB_USER" --database_password="$DB_PASS" \
    --datastore_user="$STORE_USER" --datastore_password="$STORE_PASS"
```

### Instalación avanzada

La instalación avanzada está pensada para usarios que quieren ver cómo funciona internamente `Andino`

Para instalar y ejecutar Andino, seguimos estos pasos:

+ Paso 1: Clonar repositorio.

                $ sudo mkdir /etc/andino
                $ cd /etc/andino
                $ sudo git clone https://github.com/datosgobar/portal-andino.git .

+ Paso 2: Setear las variables de entorno para el contenedor de postgresql

        $ DB_USER=<my user>
        $ DB_PASS=<my pass>
        $ sudo su -c "echo POSTGRES_USER=$DB_USER > .env"
        $ sudo su -c "echo POSTGRES_PASSWORD=$DB_PASS >> .env"
        $ sudo su -c "echo NGINX_HOST_PORT=80 >> .env"
        $ sudo su -c "echo DATASTORE_HOST_PORT=8800 >> .env"


+ Paso 3: _construir y lanzar los contenedor de servicios usando el archivo **latest.yml**_

        $ docker-compose -f latest.yml up -d db postfix redis solr

+ Paso 4: _construir y lanzar el contenedor de **andino** usando el archivo **latest.yml**_

		$ docker-compose -f latest.yml up -d portal

+ Paso 5: Inicializar la base de datos y la configuración de la aplicación:


```bash
EMAIL=admin@example.com
HOST=datos.gob.ar
DB_USER=<my db user>
DB_PASS=<my db pass>
STORE_USER=<my datastore user>
STORE_PASS=<my datastore password>
docker-compose -f latest.yml exec portal /etc/ckan_init.d/init.sh -e "$EMAIL" -h "$HOST" \
        -p "$DB_USER" -P "$DB_PASS" \
        -d "$STORE_USER" -D "$STORE_PASS"

```

+ Paso 8: _construir el contenedor de **nginx** usando el archivo **latest.yml**_

		$ docker-compose -f latest.yml up -d nginx


## Uso

Despues de instalar la aplicacion *con el script de instalación*, encontraremos en el directorio `/etc/andino/` los archivo de la aplicación.
Ademas en el mismo hay un archivo que nos permite controlar la aplicación: `andino-ctl`.
Podemos ver los comandos de este archivo corriendo: `andino-ctl --help`.

Mas información en la [guía de uso](setup/usage.md).
