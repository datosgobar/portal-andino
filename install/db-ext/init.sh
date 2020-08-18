#!/usr/bin/env bash
current_dir="$(dirname "$0")"
usage() {
	echo "Usage: `basename $0`" >&2
	echo "(-e error_email_from)" >&2
	echo "(-h site_host or ip)" >&2
	echo "(-p database_user) (-P database_password)" >&2
	echo "(-d datastore_user) (-D datastore_password)" >&2
	echo "(-H database_host) (-J database_port)" >&2
}
if ( ! getopts "e:h:p:P:d:D:H:J:" opt); then
    usage;
	exit $E_OPTERROR;
fi

while getopts "e:h:p:P:d:D:H:J:" opt;do
	case "$opt" in
	e)
	  error_email="$OPTARG"
      ;;
	h)
	  site_host="$OPTARG"
      ;;
	p)
	  database_user="$OPTARG"
      ;;
	P)
	  database_password="$OPTARG"
      ;;
	d)
	  datastore_user="$OPTARG"
      ;;
	D)
	  datastore_password="$OPTARG"
      ;;
	H)
	  database_host="$OPTARG"
      ;;
	J)
	  database_port="$OPTARG"
      ;;
	\?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
	esac
done

if [ -z "$database_host" ]; then
	database_host=db;
fi

if [ -z "$database_port" ]; then
	database_port=5432;
fi

export PGHOST="$database_host"
export PGPORT="$database_port"
export PGDATABASE=ckan
export DATASTORE_DB=datastore_default
export PGUSER="$database_user"
export PGPASSWORD="$database_password"

# Waiting for db
until psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"


#beaker_session_secret=$(openssl rand -base64 25)
beaker_session_secret="Wh90b0WNr1H8gvSuLIEPgnrlbxx/zqcgVw=="
psql -c "CREATE ROLE  \"$datastore_user\" WITH PASSWORD '$datastore_password';"
psql -c "CREATE DATABASE \"$DATASTORE_DB\" OWNER '$database_user';"

"$current_dir/change_datapusher_url.sh" "http://0.0.0.0:8800"
"$current_dir/update_conf.sh" "email_to=$error_email"
"$current_dir/change_site_url.sh" "http://$SITE_HOST"
"$current_dir/update_conf.sh" "sqlalchemy.url=postgresql://$database_user:$database_password@$PGHOST:$PGPORT/$PGDATABASE"
"$current_dir/update_conf.sh" "ckan.datastore.write_url=postgresql://$database_user:$database_password@$PGHOST:$PGPORT/$DATASTORE_DB"
"$current_dir/update_conf.sh" "ckan.datastore.read_url=postgresql://$datastore_user:$datastore_password@$PGHOST:$PGPORT/$DATASTORE_DB"
"$current_dir/update_conf.sh" "beaker.session.secret=$beaker_session_secret"

# Create datastore role and database
"$current_dir/paster.sh" --plugin=ckan db init
"$current_dir/paster.sh" --plugin=ckan datastore set-permissions| psql --set ON_ERROR_STOP=1

"$current_dir/update_data_json_and_catalog_xlsx.sh"
