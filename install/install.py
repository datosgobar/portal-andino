#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import subprocess
import time
from os import path, geteuid, makedirs, getcwd, chdir, symlink, chmod, stat


def check_permissions():
    if geteuid() != 0:
        print("[ ERROR ] Se necesitan permisos de root (sudo).")
        exit(1)


def check_docker():
    subprocess.check_call([
        "docker",
        "ps"
    ])


def check_installdir(base_path):
    if path.isdir(base_path):
        print("[ ERROR ] Se encontró instalación previa en %s, aborando." % base_path)
        print("[ ERROR ] El directorio no debería existir.")
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
    with open(env_file_path, "w") as env_f:
        env_f.write("POSTGRES_USER=%s\n" % cfg.database_user)
        env_f.write("POSTGRES_PASSWORD=%s\n" % cfg.database_password)
        env_f.write("NGINX_HOST_PORT=%s\n" % cfg.nginx_port)
        env_f.write("DATASTORE_HOST_PORT=%s\n" % cfg.datastore_port)
        env_f.write("maildomain=%s\n" % cfg.site_host)


def pull_application(base_path, compose_path):
    current_path = getcwd()  # Change to docker-compose file's directory
    chdir(base_path)
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "pull",
    ])
    chdir(current_path)  # Go back


def init_application(base_path, compose_path):
    current_path = getcwd()  # Change to docker-compose file's directory
    chdir(base_path)
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "up",
        "-d",
        "nginx",
    ])
    chdir(current_path)  # Go back


def configure_application(base_path, compose_path, cfg):
    current_path = getcwd()
    chdir(base_path)
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
    chdir(current_path)


def install_andino(cfg, compose_file_url):
    # Check
    directory = cfg.install_directory
    print("[ INFO ] Comprobando permisos (sudo)")
    check_permissions()
    print("[ INFO ] Comprobando instalación previa")
    check_installdir(directory)
    print("[ INFO ] Comprobando que docker esté instalado...")
    check_docker()
    print("[ INFO ] Comprobando que docker-compose este instalado...")
    check_compose()

    # Download and install
    print("[ INFO ] Descargando archivos necesarios...")
    compose_file_path = get_compose_file(directory, compose_file_url)
    print("[ INFO ] Escribiendo archivo de configuración del ambiente (.env) ...")
    configure_env_file(directory, cfg)
    print("[ INFO ] Obteniendo imagenes de Docker")
    pull_application(directory, compose_file_path)

    # Configure
    print("[ INFO ] Iniciando la aplicación")
    init_application(directory, compose_file_path)
    print("[ INFO ] Espetando a que la base de datos este disponible...")
    time.sleep(10)
    print("[ INFO ] Configurando...")
    configure_application(directory, compose_file_path, cfg)
    print("[ INFO ] Listo.")


def parse_args():
    parser = argparse.ArgumentParser(description='Instalar andino con docker.')

    parser.add_argument('--error_email', required=True)
    parser.add_argument('--site_host', required=True)
    parser.add_argument('--database_user', required=True)
    parser.add_argument('--database_password', required=True)
    parser.add_argument('--datastore_user', required=True)
    parser.add_argument('--datastore_password', required=True)

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
