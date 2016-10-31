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

set -eu

CONFIG="${CKAN_CONFIG}/${CKAN_CONFIG_FILE}"

abort () {
  echo "$@" >&2
  exit 1
}

write_config () {
  CKAN_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
  "$CKAN_HOME"/bin/paster make-config ckan "$CONFIG"

  "$CKAN_HOME"/bin/paster --plugin=ckan config-tool "$CONFIG" -e \
      "sqlalchemy.url = ${DATABASE_URL}" \
      "solr_url = ${SOLR_URL}" \
      "ckan.storage_path = ${CKAN_DATA}" \
      "ckan.plugins = harvest ckan_harvester stats text_view image_view recline_view hierarchy_display hierarchy_form gobar_theme datastore datapusher"  \
      "ckan.auth.create_user_via_api = false" \
      "ckan.auth.create_user_via_web = false" \
      "ckan.locale_default = es" \
      "email_to = disabled@example.com" \
      "ckan.datapusher.url = http://${CKAN_IP}:8800" \
      "ckan.datapusher.formats = csv xls xlsx tsv application/csv application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" \
      "ckan.datastore.write_url = $(link_rw_datastore)" \
      "ckan.datastore.read_url = $(link_ro_datastore)" \
      "ckan.max_resource_size = 300" \
      "error_email_from = ckan@$(hostname -f)" \
      "ckan.site_url = http://${CKAN_IP}"

  if [ -n "$ERROR_EMAIL" ]; then
    sed -i -e "s&^#email_to.*&email_to = ${ERROR_EMAIL}&" "$CONFIG"
  fi
}


link_rw_datastore (){
  local user=$DB_ENV_POSTGRES_USER
  local pass=$DB_ENV_POSTGRES_PASS
  local db=$DB_ENV_POSTGRES_DB
  local host=$DB_PORT_5432_TCP_ADDR
  local port=$DB_PORT_5432_TCP_PORT
  echo "postgresql://${user}:${pass}@${host}:${port}/datastore_default"
}


link_ro_datastore (){
  local user=$DB_ENV_POSTGRES_USER
  local pass=$DB_ENV_POSTGRES_PASS
  local db=$DB_ENV_POSTGRES_DB
  local host=$DB_PORT_5432_TCP_ADDR
  local port=$DB_PORT_5432_TCP_PORT
  echo "postgresql://datastore_default:pass@${host}:${port}/datastore_default"
}

link_postgres_url () {
  local user=$DB_ENV_POSTGRES_USER
  local pass=$DB_ENV_POSTGRES_PASS
  local db=$DB_ENV_POSTGRES_DB
  local host=$DB_PORT_5432_TCP_ADDR
  local port=$DB_PORT_5432_TCP_PORT
  echo "postgresql://${user}:${pass}@${host}:${port}/${db}"
}

link_solr_url () {
  local host=$SOLR_PORT_8983_TCP_ADDR
  local port=$SOLR_PORT_8983_TCP_PORT
  echo "http://${host}:${port}/solr/ckan"
}



# If we don't already have a config file, bootstrap
if [ ! -e "$CONFIG" ]; then
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
fi