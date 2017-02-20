#!/bin/sh

# URL for the primary database, in the format expected by sqlalchemy (required
# unless linked to a container called 'db')
: ${DATABASE_URL:=}
# URL for solr (required unless linked to a container called 'solr')
: ${SOLR_URL:=}
# Email to which errors should be sent (optional, default: none)
: ${ERROR_EMAIL:=}

: ${DATASTORE_URL_RO:=}
: ${DATASTORE_URL_RW:=}

CONFIG="/etc/ckan/default/test-core.ini"

abort () {
  echo "$@" >&2
  exit 1
}

write_config () {
  echo "Configurando DB, Solr, Datastore y Datapusher..."
  CKAN_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

  "$CKAN_HOME"/bin/paster --plugin=ckan config-tool "$CONFIG" -e \
      "sqlalchemy.url = ${DATABASE_URL}" \
      "solr_url = ${SOLR_URL}" \
      "ckan.datapusher.url = http://${CKAN_IP}:8800" \
      "ckan.datastore.write_url = $(link_rw_datastore)" \
      "ckan.datastore.read_url = $(link_ro_datastore)"
}


link_rw_datastore (){
  local user=$DB_ENV_POSTGRES_USER
  local pass=$DB_ENV_POSTGRES_PASS
  local db=$DB_ENV_POSTGRES_DB
  local host=$DB_PORT_5432_TCP_ADDR
  local port=$DB_PORT_5432_TCP_PORT
  echo "postgresql://${user}:${pass}@${host}:${port}/ckan_datastore_test"
}


link_ro_datastore (){
  local user=$DB_ENV_POSTGRES_USER
  local pass=$DB_ENV_POSTGRES_PASS
  local db=$DB_ENV_POSTGRES_DB
  local host=$DB_PORT_5432_TCP_ADDR
  local port=$DB_PORT_5432_TCP_PORT
  echo "postgresql://datastore_default:pass@${host}:${port}/ckan_datastore_test"
}

link_postgres_url () {
  local user=$DB_ENV_POSTGRES_USER
  local pass=$DB_ENV_POSTGRES_PASS
  local db="ckan_test"
  local host=$DB_PORT_5432_TCP_ADDR
  local port=$DB_PORT_5432_TCP_PORT
  echo "postgresql://${user}:${pass}@${host}:${port}/${db}"
}

link_solr_url () {
  local host=$SOLR_PORT_8983_TCP_ADDR
  local port=$SOLR_PORT_8983_TCP_PORT
  echo "http://${host}:${port}/solr/ckan"
}



if [ -z "$DATABASE_URL" ]; then
  if ! DATABASE_URL=$(link_postgres_url); then
    abort "Imposible conectar DATABASE_URL ..."
  fi
fi
if [ -z "$SOLR_URL" ]; then
  if ! SOLR_URL=$(link_solr_url); then
    abort "Imposible conectar SOLR_URL ..."
  fi
fi
write_config
