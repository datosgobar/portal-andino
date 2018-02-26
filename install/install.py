#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import logging
import subprocess
import time
from os import path, geteuid, makedirs, getcwd, chdir

logger = logging.getLogger(__file__)
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
formatter = logging.Formatter('[ %(levelname)s ] %(message)s')
ch.setFormatter(formatter)
logger.addHandler(ch)



class ComposeContext:
    def __init__(self, compose_path):
        self.compose_path = compose_path

    def __enter__(self):
        self.current_path = getcwd()
        chdir(self.compose_path)  # Change to docker-compose file's directory

    def __exit__(self, type, value, traceback):
        chdir(self.current_path)  # Go back


def check_permissions():
    if geteuid() != 0:
        logger.error("Se necesitan permisos de root (sudo).")
        exit(1)


def check_docker():
    subprocess.check_call([
        "docker",
        "ps"
    ])


def check_installdir(base_path):
    if path.isdir(base_path):
        logger.error("Se encontró instalación previa en %s, aborando." % base_path)
        logger.error("El directorio no debería existir.")
        exit(1)
    else:
        makedirs(base_path)


def check_compose():
    subprocess.check_call([
        "docker-compose",
        "--version",
    ])


def get_compose_file(base_path, download_url):
    compose_file = "latest.yml"
    compose_file_path = path.join(base_path, compose_file)
    subprocess.check_call([
        "curl",
        download_url,
        "--fail",
        "--output",
        compose_file_path
    ])
    return compose_file_path


def configure_env_file(base_path, cfg):
    env_file = ".env"
    env_file_path = path.join(base_path, env_file)
    if cfg.andino_version:
        andino_version = cfg.andino_version
    else:
        raise Exception("La version de andino no fue especificada.")
    with open(env_file_path, "w") as env_f:
        env_f.write("POSTGRES_USER=%s\n" % cfg.database_user)
        env_f.write("ANDINO_TAG=%s\n" % andino_version)
        env_f.write("POSTGRES_PASSWORD=%s\n" % cfg.database_password)
        env_f.write("NGINX_HOST_PORT=%s\n" % cfg.nginx_port)
        env_f.write("DATASTORE_HOST_PORT=%s\n" % cfg.datastore_port)
        env_f.write("maildomain=%s\n" % cfg.site_host)


def pull_application(compose_path):
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "pull",
    ])


def init_application(compose_path):
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "up",
        "-d",
        "nginx",
    ])


def configure_application(compose_path, cfg):
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "exec",
        "-T",
        "portal",
        "/etc/ckan_init.d/init.sh",
        "-e", cfg.error_email,
        "-h", cfg.site_host,
        "-p", cfg.database_user,
        "-P", cfg.database_password,
        "-d", cfg.datastore_user,
        "-D", cfg.datastore_password,
    ])


def install_andino(cfg, compose_file_url):
    # Check
    directory = cfg.install_directory
    logger.info("Comprobando permisos (sudo)")
    check_permissions()
    logger.info("Comprobando instalación previa")
    check_installdir(directory)
    logger.info("Comprobando que docker esté instalado...")
    check_docker()
    logger.info("Comprobando que docker-compose este instalado...")
    check_compose()

    # Download and install
    logger.info("Descargando archivos necesarios...")
    compose_file_path = get_compose_file(directory, compose_file_url)
    logger.info("Escribiendo archivo de configuración del ambiente (.env) ...")
    configure_env_file(directory, cfg)
    with ComposeContext(directory):
        logger.info("Obteniendo imagenes de Docker")
        pull_application(compose_file_path)
        # Configure
        logger.info("Iniciando la aplicación")
        init_application(compose_file_path)
        logger.info("Espetando a que la base de datos este disponible...")
        time.sleep(10)
        logger.info("Configurando...")
        configure_application(compose_file_path, cfg)
        logger.info("Listo.")


def parse_args():
    parser = argparse.ArgumentParser(description='Instalar andino con docker.')

    parser.add_argument('--error_email', required=True)
    parser.add_argument('--site_host', required=True)
    parser.add_argument('--database_user', required=True)
    parser.add_argument('--database_password', required=True)
    parser.add_argument('--datastore_user', required=True)
    parser.add_argument('--datastore_password', required=True)

    parser.add_argument('--andino_version')
    parser.add_argument('--nginx_port', default="80")
    parser.add_argument('--datastore_port', default="8800")
    parser.add_argument('--branch', default='master')
    parser.add_argument('--install_directory', default='/etc/portal/')

    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()

    base_url = "https://raw.githubusercontent.com/datosgobar/portal-andino"
    branch = args.branch
    file_name = "latest.yml"

    install_andino(args, path.join(base_url, branch, file_name))
