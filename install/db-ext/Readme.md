## Instlar Andino en una DB externa al stack

## Configurar production.ini

editar el archivo insatll/db-ext/producion.ini

- ckan.owner.email = admin@example.com
- beaker.session.secret = Wh90b0WNr1H8gvSuLIEPgnrlbxx/zqcgVw==
- sqlalchemy.url = postgresql://postgres:example@localhost:5432/ckan
- ckan.datastore.write_url = postgresql://postgres:example@localhost:5432/datastore_default
- ckan.datastore.read_url = postgresql://storeandino:storepass1234@localhost:5432/datastore_default
- ckan.site_url = http://localhost
- email_to = admin@example.com


## Compilar la imagen

docker build -t datosgcba/portal-badata:release-2.6.3-db-ext .
docker-compose -f db-ext.yml up -d
