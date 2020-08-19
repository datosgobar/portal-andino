## Instlar Andino en una DB externa al stack

## Configurar production.ini

editar el archivo install/db-ext/production.ini

- ckan.owner.email = admin@example.com
- beaker.session.secret = Wh90b0WNr1H8gvSuLIEPgnrlbxx/zqcgVw==
- sqlalchemy.url = postgresql://postgres:example@localhost:5432/ckan
- ckan.datastore.write_url = postgresql://postgres:example@localhost:5432/datastore_default
- ckan.datastore.read_url = postgresql://storeandino:storepass1234@localhost:5432/datastore_default
- ckan.site_url = http://localhost
- email_to = admin@example.com

## Requisitos

Servidor de Base de datos


Usuario con privilegios de administrador
base de datos con nombre ckan

## Compilar la imagen

docker build -t datosgcba/portal-badata:release-2.6.3-db-ext .

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
