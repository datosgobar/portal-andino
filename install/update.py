#!/usr/bin/env python
# -*- coding: utf-8 -*-
import argparse
import logging
import shutil
import subprocess
import time
import sys
from os import path, geteuid, getcwd, chdir

logger = logging.getLogger(__file__)
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler(stream=sys.stdout)
formatter = logging.Formatter('[ %(levelname)s ] %(message)s')
ch.setFormatter(formatter)
logger.addHandler(ch)

UPGRADE_DB_COMMAND = "/etc/ckan_init.d/upgrade_db.sh"
REBUILD_SEARCH_COMMAND = "/etc/ckan_init.d/run_rebuild_search.sh"

nginx_ssl_config_directory = '/etc/nginx/ssl'


class ComposeContext:
    def __init__(self, compose_path):
        self.compose_path = compose_path

    def __enter__(self):
        self.current_path = getcwd()
        chdir(self.compose_path)  # Change to docker-compose file's directory

    def __exit__(self, type, value, traceback):
        chdir(self.current_path)  # Go back


def ask(question):
    try:
        _ask = raw_input
    except NameError:
        _ask = input
    return _ask("%s\n" % question)


def check_permissions():
    if geteuid() != 0:
        logging.error("Se necesitan permisos de root (sudo).")
        exit(1)


def check_docker():
    subprocess.check_call([
        "docker",
        "ps"
    ])


def check_compose():
    subprocess.check_call([
        "docker-compose",
        "--version",
    ])


def download_file(file_path, download_url):
    subprocess.check_call([
        "curl",
        download_url,
        "--fail",
        "--output",
        file_path
    ])


def download_compose_file(compose_path, download_url):
    download_file(compose_path, download_url)


def get_compose_file_path(base_path):
    compose_file = "latest.yml"
    return path.join(base_path, compose_file)


def get_stable_version_file(base_path, download_url):
    compose_file = "stable_version.yml"
    stable_version_path = path.join(base_path, compose_file)
    download_file(stable_version_path, download_url)
    return stable_version_path


def check_nginx_ssl_files_exist(cfg):
    if path.isfile(cfg.ssl_crt_path) and path.isfile(cfg.ssl_key_path):
        return True
    else:
        # Chequeo si los archivos ya existen en el contenedor de Nginx, para no tener que pasarlos siempre
        if subprocess.check_output("docker exec -it andino-nginx bash -c "
                                   "'if [[ -f \"$NGINX_SSL_CONFIG_DATA/andino.key\" ]]  ; then echo \"Y\" ; "
                                   "else echo \"N\" ; fi'", shell=True).strip() == 'Y' and \
            subprocess.check_output("docker exec -it andino-nginx bash -c "
                                    "'if [[ -f \"$NGINX_SSL_CONFIG_DATA/andino.crt\" ]] ; then echo \"Y\" ; "
                                    "else echo \"N\" ; fi'", shell=True).strip() == 'Y':
            return True
    return False


def get_nginx_configuration(cfg):
    if cfg.nginx_ssl:
        if check_nginx_ssl_files_exist(cfg):
            return "nginx_ssl.conf"
    logger.error("No se puede utilizar el archivo de configuración para SSL debido a que falta al menos un "
                 "archivo para el certificado. Se utilizará el default en su lugar.")
    return "nginx.conf"


def get_andino_version(cfg, base_path, stable_version_url):
    if cfg.andino_version:
        andino_version = cfg.andino_version
    else:
        logger.info("Configurando version estable de andino.")
        stable_version_path = get_stable_version_file(base_path, stable_version_url)
        with file(stable_version_path, "r") as f:
            content = f.read()
        andino_version = content.strip()
    logger.info("Usando version '%s' de andino" % andino_version)
    return andino_version


def update_env(base_path, cfg, stable_version_url):
    env_file = ".env"
    env_file_path = path.join(base_path, env_file)
    envconf = {}
    nginx_config_file = "NGINX_CONFIG_FILE"
    nginx_extended_cache = "NGINX_EXTENDED_CACHE"
    nginx_cache_max_size = "NGINX_CACHE_MAX_SIZE"
    nginx_cache_inactive = "NGINX_CACHE_INACTIVE"
    # Get current variables
    with open(env_file_path, "r") as env_f:
        for line in env_f.readlines():
            try:
                key, value = line.split("=", 1)
                envconf[key] = value.strip()
            except ValueError as e:
                logger.warn("Ignorando linea '%s'" % line)
    # Backup current config
    datetime_var = time.strftime("__%d_%m_%y-%H-%M")
    backup_env_file = "%s%s" % (env_file, datetime_var)
    backup_env_file_path = path.join(base_path, backup_env_file)
    shutil.move(env_file_path, backup_env_file_path)

    # Write new config
    envconf["ANDINO_TAG"] = get_andino_version(cfg, base_path, stable_version_url)
    with open(env_file_path, "w") as env_f:
        for key in envconf.keys():
            env_f.write("%s=%s\n" % (key, envconf[key]))
        if nginx_config_file not in envconf.keys() or cfg.nginx_ssl:
            env_f.write("NGINX_CONFIG_FILE=%s\n" % get_nginx_configuration(cfg))
        if nginx_extended_cache not in envconf.keys():
            env_f.write("NGINX_EXTENDED_CACHE=%s\n" % "yes" if cfg.nginx_extended_cache else "no")
        if nginx_cache_max_size not in envconf.keys() or cfg.nginx_cache_max_size:
            env_f.write("NGINX_CACHE_MAX_SIZE=%s\n" % cfg.nginx_cache_max_size)
        if nginx_cache_inactive not in envconf.keys() or cfg.nginx_cache_inactive:
            env_f.write("NGINX_CACHE_INACTIVE=%s\n" % cfg.nginx_cache_inactive)


def fix_env_file(base_path):
    env_file = ".env"
    env_file_path = path.join(base_path, env_file)
    nginx_var = "NGINX_HOST_PORT"
    datastore_var = "DATASTORE_HOST_PORT"
    maildomain_var = "maildomain"
    timezone_var = "TZ"
    site_host_var = "SITE_HOST"

    with open(env_file_path, "r") as env_f:
        content = env_f.read()
    with open(env_file_path, "a") as env_f:
        if nginx_var not in content:
            env_f.write("%s=%s\n" % (nginx_var, "80"))
        if datastore_var not in content:
            env_f.write("%s=%s\n" % (datastore_var, "8800"))
        if maildomain_var not in content:
            maildomain = ask(
                "Por favor, ingrese su dominio para envío de emails (e.g.: myportal.com.ar): ")
            real_maildomain = maildomain.strip()
            if not real_maildomain:
                print("Ningun valor fue ingresado, usando valor por defecto: localhost")
                real_maildomain = "localhost"
            env_f.write("%s=%s\n" % (maildomain_var, real_maildomain))
        if timezone_var not in content:
            env_f.write("%s=%s\n" % (timezone_var, "America/Argentina/Buenos_Aires"))
        if site_host_var not in content:
            env_f.write("%s=%s\n" % (site_host_var, "andino_nginx"))


def backup_database(base_path, compose_path):
    db_container = subprocess.check_output(["docker-compose", "-f", compose_path, "ps", "-q", "db"])
    db_container = db_container.decode("utf-8").strip()
    cmd = [
        "docker",
        "exec",
        db_container,
        "bash",
        "-lc",
        "env PGPASSWORD=$POSTGRES_PASSWORD pg_dump --format=custom -U $POSTGRES_USER $POSTGRES_DB",
    ]
    output = subprocess.check_output(cmd)
    dump_name = "%s-ckan.dump" % time.strftime("%d:%m:%Y:%H:%M:%S")
    dump = path.join(base_path, dump_name)
    with open(dump, "wb") as a_file:
        a_file.write(output)


def pull_application(compose_path):
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "pull",
    ])


def persist_ssl_certificates(cfg):
    subprocess.check_call([
        "docker",
        "cp",
        cfg.ssl_key_path,
        'andino-nginx:{0}/andino.key'.format(nginx_ssl_config_directory)
    ])
    subprocess.check_call([
        "docker",
        "cp",
        cfg.ssl_crt_path,
        'andino-nginx:{0}/andino.crt'.format(nginx_ssl_config_directory)
    ])


def reload_application(compose_path):
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "up",
        "-d",
        "nginx",
    ])


def check_previous_installation(base_path):
    compose_file = "latest.yml"
    compose_file_path = path.join(base_path, compose_file)
    if not path.isfile(compose_file_path):
        logging.error(
            "Por favor corra este comando en el mismo directorio donde instaló la aplicación")
        logging.error("No se encontró el archivo %s en el directorio actual" % compose_file)
        raise Exception("[ ERROR ] No se encontró una instalación.")


def post_update_commands(compose_path):
    try:
        subprocess.check_call(
            ["docker-compose",
             "-f",
             compose_path,
             "exec",
             "-T",
             "portal",
             "bash",
             "/etc/ckan_init.d/run_updates.sh"
             ]
        )
    except subprocess.CalledProcessError as e:
        logging.error("Error al correr el script 'run_updates.sh'")
        logging.error(e)

    try:
        subprocess.check_call(
            ["docker-compose",
             "-f",
             compose_path,
             "exec",
             "-T",
             "portal",
             "bash",
             "/etc/ckan_init.d/update_data_json_and_catalog_xlsx.sh"
             ]
        )
    except subprocess.CalledProcessError as e:
        logging.error("Error al correr el script 'update_data_json_and_catalog_xlsx.sh'")
        logging.error(e)

    all_plugins = subprocess.check_output(
        ["docker-compose",
         "-f",
         compose_path,
         "exec",
         "-T",
         "portal",
         "grep", "-E", "^ckan.plugins.*", "/etc/ckan/default/production.ini"]
    ).decode("utf-8").strip()
    subprocess.check_call(
        ["docker-compose",
         "-f",
         compose_path,
         "exec",
         "-T",
         "portal",
         "sed", "-i", "s/^ckan\.plugins.*/ckan.plugins = stats/",
         "/etc/ckan/default/production.ini"]
    )
    try:
        subprocess.check_call([
            "docker-compose",
            "-f",
            compose_path,
            "exec",
            "-T",
            "portal",
            UPGRADE_DB_COMMAND,
        ])
    finally:
        subprocess.check_call(
            ["docker-compose",
             "-f",
             compose_path,
             "exec",
             "-T",
             "portal",
             "sed", "-i", "s/^ckan\.plugins.*/%s/" % all_plugins, "/etc/ckan/default/production.ini"]
        )
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "exec",
        "-T",
        "portal",
        REBUILD_SEARCH_COMMAND,
    ])


def restart_apps(compose_path):
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "restart",
    ])


def configure_nginx_extended_cache(compose_path):
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "exec",
        "-T",
        "portal",
        "/etc/ckan_init.d/update_conf.sh",
        "andino.cache_clean_hook=http://nginx/meta/cache/purge",
    ])
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "exec",
        "-T",
        "portal",
        "/etc/ckan_init.d/update_conf.sh",
        "andino.cache_clean_hook_method=PURGE",
    ])


def include_necessary_nginx_configuration(filename):
    subprocess.check_call([
        "docker",
        "exec",
        "-d",
        "andino-nginx",
        "/etc/nginx/scripts/{0}".format(filename)
    ])


def update_andino(cfg, compose_file_url, stable_version_url):
    directory = cfg.install_directory
    logging.info("Comprobando permisos (sudo)")
    check_permissions()
    logging.info("Comprobando que docker esté instalado...")
    check_docker()
    logging.info("Comprobando que docker-compose este instalado...")
    check_compose()
    logging.info("Comprobando instalación previa...")
    check_previous_installation(directory)
    compose_file_path = get_compose_file_path(directory)
    fix_env_file(directory)

    with ComposeContext(directory):
        logging.info("Guardando base de datos...")
        backup_database(directory, compose_file_path)
        logging.info("Actualizando la aplicación")
        logging.info("Descargando archivos necesarios...")
        download_compose_file(compose_file_path, compose_file_url)
        update_env(directory, cfg, stable_version_url)
        logging.info("Descargando nuevas imagenes...")
        # pull_application(compose_file_path)
        if cfg.nginx_extended_cache:
            logger.info("Configurando caché extendida de nginx")
            configure_nginx_extended_cache(compose_file_path)
            include_necessary_nginx_configuration("extend_nginx.sh")
        if cfg.ssl_crt_path and cfg.ssl_key_path:
            logger.info("Copiando archivos del certificado de SSL")
            if path.isfile(cfg.ssl_crt_path) and path.isfile(cfg.ssl_key_path):
                persist_ssl_certificates(cfg)
            else:
                logger.error("No se pudo encontrar al menos uno de los archivos, por lo que no se realizará el copiado")
        reload_application(compose_file_path)
        logging.info("Corriendo comandos post-instalación")
        post_update_commands(compose_file_path)
        logging.info("Reiniciando")
        restart_apps(compose_file_path)
        logging.info("Listo.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Actualizar andino.')

    parser.add_argument('--branch', default='master')
    parser.add_argument('--install_directory', default='/etc/portal/')
    parser.add_argument('--andino_version')
    parser.add_argument('--nginx-extended-cache', action="store_true")
    parser.add_argument('--nginx-cache-max-size', default="")
    parser.add_argument('--nginx-cache-inactive', default="")
    parser.add_argument('--nginx_ssl', action="store_true")
    parser.add_argument('--ssl_key_path', default="")
    parser.add_argument('--ssl_crt_path', default="")
    args = parser.parse_args()

    base_url = "https://raw.githubusercontent.com/datosgobar/portal-andino"
    branch = args.branch
    file_name = "latest.yml"
    stable_version_file_nane = "stable_version.txt"

    compose_file_download_url = path.join(base_url, branch, file_name)
    stable_version_url = path.join(base_url, branch, "install", stable_version_file_nane)

    update_andino(args, compose_file_download_url, stable_version_url)
