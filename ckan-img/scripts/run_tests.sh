#!/bin/sh

${CKAN_HOME}/bin/pip install -r ${CKAN_HOME}/src/ckan/dev-requirements.txt

export PGUSER=$DB_ENV_POSTGRES_USER;
export PGPASSWORD=$DB_ENV_POSTGRES_PASS;
export PGHOST=$DB_PORT_5432_TCP_ADDR;
export PGDATABASE=$DB_ENV_POSTGRES_DB;
export PGPORT=$DB_PORT_5432_TCP_PORT;

init_db(){
	psql -c "CREATE DATABASE ckan_test OWNER $PGUSER;"
	psql -c "CREATE DATABASE ckan_datastore_test OWNER $PGUSER;"
}

drop_db() {
	psql -c "DROP DATABASE ckan_test;"
	psql -c "DROP DATABASE ckan_datastore_test;"
}
printf "Inicializando bases de datos... "
init_db

printf "[OK]\nBases de datos funcionales y listas!\n"
${CKAN_HOME}/bin/nosetests --ckan --reset-db --with-pylons="$CKAN_CONFIG/test-core.ini" ckan
drop_db
