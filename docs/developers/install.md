<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Indice

- [Instalación](#instalacion)
  - [Dependencias](#dependencias)
  - [Instalación simplificada de andino](#instalacion-simplificada-de-andino)
  - [Instalación avanzada de andino](#instalacion-avanzada-de-andino)
  - [Desinstalar andino](#desinstalar-andino)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Instalación

Teniendo en cuenta la dificultad de implementación e incluso la cantidad de pasos para lograr un deploy existoso, 
existen dos formas de instalar esta distribución de **CKAN**.

- Si no tenés muchos conocimientos de CKAN, Docker o de administracién de servidores en general, es recomendable 
usar la instalación **[simplificada  de Andino](#instalacion-simplificada-de-andino)**. 
Está pensada para que, en la menor cantidad de pasos y de manera sencilla, tengas un portal de datos funcionando. 
- Si ya conocés la plataforma, tenés experiencia con Docker o, simplemente, querés entender cómo funciona 
esta implementación, te sugiero que revises la **[instalacion avanzada de Andino](#instalacion-avanzada-de-andino)**

## Dependencias

- DOCKER: [Guía de instalación](https://docs.docker.com/engine/installation).
  - Versión mínima _testeada_: `1.13.1`
- Docker Compose: [Guía de instalación](https://docs.docker.com/compose/install/).
  - Versión mínima _testeada_: `1.12.0`

## Instalación simplificada de andino

La idea detrás de esta implementación de CKAN es **que sólo te encargues de tus datos**, nada más. 
Por eso, si "copiás y pegás" el comando de consola, en sólo unos momentos, tendrás un Andino listo para usar.
Esta clase de instalación no requiere que clones el repositorio, ya que usamos contenedores alojados en 
[DockerHub](https://hub.docker.com/r/datosgobar)

+ Ubuntu|Debian|RHEL|CentOS:
+ Instalación:

Para la instalación, usamos un script de python llamado 
[`install.py`](https://github.com/datosgobar/portal-andino/blob/master/install/install.py).
El mismo requiere algunos parámetros específicos, y existen otros que son opcionales:

```bash
# Parametros de install.py
    [-h]                    Mostrar la ayuda del script
    --error_email           Email donde se mandaran los errores del portal de ser necesario
    --site_host             Dominio o IP del la aplicación *sin el protocolo*
    --database_user         Nombre del usuario de la base de datos a crear
    --database_password     Contraseña de la base de datos a crear
    --datastore_user        Nombre del usuario de la base de datos del datastore a crear
    --datastore_password    Contraseña de la base de datos del datastore a crear
    [--nginx-extended-cache]
        Configura nginx con una configuración extendida y configura el hook de
        invalidación de cache de Andino para notificar a nginx
    [--nginx_ssl]
        Aplica la configuración HTTPS en nginx. Requiere ambos archivos del certificado SSL para poder lograrlo; en 
        caso contrario, se utilizará la configuración default
    [--ssl_key_path SSL_KEY_PATH]
        Path dentro del host donde está ubicado el archivo .key para el certificado SSL; será copiado al contenedor 
        de nginx si tanto éste como el .crt pueden ser encontrados
    [--ssl_crt_path SSL_CRT_PATH]
        Path dentro del host donde está ubicado el archivo .crt para el certificado SSL; será copiado al contenedor 
        de nginx si tanto éste como el .key pueden ser encontrados
    [--nginx_port NGINX_PORT]
        Puerto del servidor "Host" que se desea que se tome para recibir llamadas HTTP.
        Por defecto es el 80.
    [--nginx_ssl_port NGINX_SSL_PORT]
        Puerto del servidor "Host" que se desea que se tome para recibir llamadas HTTPS.
        Por defecto es el 443.
        Es importante para los administradores saber que Andino tomará el puerto especificado (o el default) ya sea que el portal use o no use HTTPS. En caso de no querer usar HTTPS y que el host tenga erl puerto 443 tomado por un servidor web, es requisito especificar un puerto distinto (ejemplo: 8443) que será reservado por Andino, pero no utilizado.
    [--datastore_port DATASTORE_PORT]
        Puerto del servidor "Host" que se desea que se tome para recibir llamadas HTTP al "datastore".
        Por defecto es el 8800.
    [--install_directory INSTALL_DIRECTORY]
        Directorio donde se desea instalar la aplicación.
        Por defecto es `/etc/portal` (recomendado)

```

Para esta instalación de ejemplo, usaremos estos parámetros para la aplicación.
Para los demás, usaremos los valores por defecto:

+ Email donde se mandarán los errores. `EMAIL=admin@example.com`
+ Dominio o IP de la aplicación _sin el protocolo_: `HOST=datos.gob.ar`
+ Usuario de la base de datos: `DB_USER=<my db user>`
+ Password de la base de datos: `DB_PASS=<my db pass>`
+ Usuario del datastore: `STORE_USER=<my datastore user>`
+ Password del datastore: `STORE_PASS=<my datastore password>`

NOTA: Si usamos una IP para la variable `HOST`, el envio de mails no funcionará.
Postfix require un "fully-qualified domain name (FQDN)". 
Ver [la documentación de Postfix](http://www.postfix.org/postconf.5.html#myhostname) para más detalles.

```bash
# Primero especificamos los valores necesarios

EMAIL=admin@example.com
HOST=andino.midominio.com.ar
DB_USER=my_database_user
DB_PASS=my_database_pass
STORE_USER=my_data_user
STORE_PASS=my_data_pass

wget https://raw.github.com/datosgobar/portal-andino/master/install/install.py

sudo python ./install.py \
    --error_email "$EMAIL" \
    --site_host="$HOST" \
    --database_user="$DB_USER" \
    --database_password="$DB_PASS" \
    --datastore_user="$STORE_USER" \
    --datastore_password="$STORE_PASS"
```

## Instalación avanzada de andino

La instalación avanzada está pensada para usuarios que quieren ver cómo funciona internamente `Andino`

Para instalar y ejecutar Andino, seguiremos estos pasos:

+ Paso 1: Clonar repositorio.

```bash
sudo mkdir /etc/portal
cd /etc/portal
sudo git clone https://github.com/datosgobar/portal-andino.git .
```
+ Paso 2: Especificar las variables de entorno para el contenedor de postgresql.

NOTA: Debemos usar un dominio válido para la variable `DOMINIO`, de otra forma el envio de mails no funcionará.
Postfix require un "fully-qualified domain name (FQDN)". 
Ver [la documentación de Postfix](http://www.postfix.org/postconf.5.html#myhostname) para más detalles.


```bash
DB_USER=<my user>
DB_PASS=<my pass>
DOMINIO=andino.midominio.com.ar
ANDINO_VERSION=<version que deseamos instalar>
sudo su -c "echo POSTGRES_USER=$DB_USER > .env"
sudo su -c "echo POSTGRES_PASSWORD=$DB_PASS >> .env"
sudo su -c "echo NGINX_HOST_PORT=80 >> .env"
sudo su -c "echo DATASTORE_HOST_PORT=8800 >> .env"
sudo su -c "echo maildomain=$DOMINIO >> .env"
sudo su -c "echo ANDINO_TAG=$ANDINO_VERSION >> .env"
```

+ Paso 3: Construir y lanzar los contenedor de servicios usando el archivo **latest.yml**

    docker-compose -f latest.yml up -d db postfix redis solr

+ Paso 4: Construir y lanzar el contenedor de **andino** usando el archivo **latest.yml**

    docker-compose -f latest.yml up -d portal

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

+ Paso 8: Construir el contenedor de **nginx** usando el archivo **latest.yml**

	$ docker-compose -f latest.yml up -d nginx

## Desinstalar andino

Esta secuencia de comandos va a ELIMINAR TODOS LOS CONTENEDORES, IMÁGENES y VOLUMENES de la aplicación de la vm donde 
está instalada la plataforma.

Esta operación no es reversible. **Perderás todos tus datos si realizas esta operación**.

```bash
app_dir="/etc/portal/"
cd $app_dir
docker-compose -f latest.yml down -v
cd ~/
sudo rm $app_dir -r
```
