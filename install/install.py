#!/usr/bin/env python
# -*- coding: utf-8 -*-
import argparse
import subprocess
import time
from os import path, geteuid, makedirs, getcwd, chdir, symlink, chmod, stat

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
parser.add_argument('--install_directory', default='/etc/andino/')

args = parser.parse_args()

REPOSITORY = "portal-andino"
CTL_FILE_NAME = "andino-ctl"
INSTALL_DIRECTORY = args.install_directory
USR_BIN_CRL = path.join("/usr/local/bin/", CTL_FILE_NAME)

COMPOSE_FILE_URL = "https://raw.githubusercontent.com/datosgobar/%s/%s/latest.yml" % (REPOSITORY, args.branch)
CTL_SCRIPT = "https://raw.githubusercontent.com/datosgobar/%s/%s/install/andino-ctl" % (REPOSITORY, args.branch)


def check_permissions():
    if geteuid() != 0:
        print("[ ERROR ] Se necesitan permisso de root (sudo).")
        exit(1)


def check_installdir(base_path):
    if path.isdir(base_path):
        print("[ ERROR ] Se encontró instalción previa en %s, aborando." % base_path)
        exit(1)
    else:
        makedirs(base_path)


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


def get_compose_file(base_path):
    compose_file = "docker-compose.yml"
    compose_file_path = path.join(base_path, compose_file)
    subprocess.check_call([
        "curl",
        COMPOSE_FILE_URL,
        "--fail",
        "--output",
        compose_file_path
    ])
    return compose_file_path


def get_ctl_script_file(base_path):
    clt_file_path = path.join(base_path, CTL_FILE_NAME)
    subprocess.check_call([
        "curl",
        CTL_SCRIPT,
        "--fail",
        "--output",
        clt_file_path
    ])
    return clt_file_path


def configure_env_file(base_path):
    env_file = ".env"
    env_file_path = path.join(base_path, env_file)
    with open(env_file_path, "w") as env_f:
        env_f.write("POSTGRES_USER=%s\n" % args.database_user)
        env_f.write("POSTGRES_PASSWORD=%s\n" % args.database_password)
        env_f.write("NGINX_HOST_PORT=%s\n" % args.nginx_port)
        env_f.write("DATASTORE_HOST_PORT=%s\n" % args.datastore_port)
        env_f.write("maildomain=%s\n" % args.site_host)


def configure_crl_file(ctl_path):
    symlink(ctl_path, USR_BIN_CRL)
    st = stat(ctl_path)
    chmod(ctl_path, st.st_mode | 0o0111)


def pull_application(base_path, compose_path):
    current_path = getcwd()
    chdir(base_path)
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "pull",
    ])
    chdir(current_path)


def init_application(base_path, compose_path):
    current_path = getcwd()
    chdir(base_path)
    subprocess.check_call([
        "docker-compose",
        "-f",
        compose_path,
        "up",
        "-d",
        "nginx",
    ])
    chdir(current_path)


def configure_application(base_path, compose_path):
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
        "-e", args.error_email,
        "-h", args.site_host,
        "-p", args.database_user,
        "-P", args.database_password,
        "-d", args.datastore_user,
        "-D", args.datastore_password,
    ])
    chdir(current_path)


print("[ INFO ] Comprobando permisos (sudo)")
check_permissions()
print("[ INFO ] Comprobando instalación previa")
directory = INSTALL_DIRECTORY
check_installdir(directory)
print("[ INFO ] Comprobando que docker esté instalado...")
check_docker()
print("[ INFO ] Comprobando que docker-compose este instalado...")
check_compose()
print("[ INFO ] Descargando archivos necesarios...")
compose_file_path = get_compose_file(directory)
ctl_script_path = get_ctl_script_file(directory)
print("[ INFO ] Escribiendo archivo de configuración del ambiente (.env) ...")
configure_env_file(directory)
print("[ INFO ] Configurando andino-ctl")
configure_crl_file(ctl_script_path)
print("[ INFO ] Obteniendo imagenes de Docker")
pull_application(directory, compose_file_path)
print("[ INFO ] Iniciando la aplicación")
init_application(directory, compose_file_path)
print("[ INFO ] Espetando a que la base de datos este disponible...")
time.sleep(10)
print("[ INFO ] Configurando...")
configure_application(directory, compose_file_path)
print("[ INFO ] Listo.")
