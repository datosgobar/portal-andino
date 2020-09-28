## Instlar Andino en una DB externa al stack

## Requisitos

Servidor de Base de datos


Usuario con privilegios de administrador. Ejemplo <usuario_admin> y <usuario_admin_password>
base de datos con nombre ckan

## Configurar production.ini
Clonar el repositorio
``` git clone https://github.com/datosgcba/portal-andino.git ```

## Configurar production.ini

Editar el archivo install/db-ext/production.ini

- ckan.owner.email = admin@example.com
- beaker.session.secret = Wh90b0WNr1H8gvSuLIEPgnrlbxx/zqcgVw==
- sqlalchemy.url = postgresql://<usuario_admin_db>:example@<ip_db>:<puerto_db>/ckan
- ckan.datastore.write_url = postgresql://<usuario_admin_db>:<usuario_admin_password>@<ip_db>:<puerto_db>/datastore_default
- ckan.datastore.read_url = postgresql://<usuario_nuevo>:<password_nuevo>@<ip_db>:<puerto_db>/datastore_default
- ckan.site_url = http://<ip_web>
- email_to = admin@example.com

``` Reemplazar <usuario_admin_password> y <usuario_admin_password> por los obtenidos en el punto anterior ```

## Compilar la imagen
Ejecutar el build de la imagen docker, no olvidar el punto del final que provee el contexto neceseario
```
docker build -t datosgcba/portal-badata:release-2.6.3-db-ext .
``` 

## Iniciar las dependencias del portal

docker-compose -f db-ext.yml up -d postfix redis solr

## Inicializar la DB

EMAIL=<email>

DB_HOST=<ip_db>

DB_PORT=<puerto_db>

HOST=<ip_web>

DB_USER=<usuario_admin_db>

DB_PASS=<password_admin_db>

STORE_USER=<usuario_nuevo>

STORE_PASS=<password_nuevo>

``` <usuario_admin_db> <password_admin_db> <usuario_nuevo> <password_nuevo> <ip_db> <puerto_db> denen coincidir con los del punto anterior ```

docker-compose -f db-ext.yml run  -e EMAIL="$EMAIL" -e HOST="$HOST" -e DB_HOST="$DB_HOST" -e DB_PORT="$DB_PORT" -e DB_USER="$DB_USER" -e DB_PASS="$DB_PASS" -e STORE_USER="$STORE_USER" -e STORE_PASS="$STORE_PASS"  portal /bin/bash


/etc/ckan_init.d/init.sh -e "$EMAIL" -h "$HOST" -H "$DB_HOST" -J "$DB_PORT" -p "$DB_USER" -P "$DB_PASS" -d "$STORE_USER" -D "$STORE_PASS" 

exit

## Iniciar el portal

docker-compose -f db-ext.yml up -d portal

docker-compose -f db-ext.yml up -d nginx

## Crear usuario administrador del portal

docker-compose -f db-ext.yml exec portal /etc/ckan_init.d/add_admin.sh admin email@example.com

## Detener el servicio

docker-compose -f db-ext.yml down

## Reniciar el servicio

docker-compose -f db-ext.yml up -d
