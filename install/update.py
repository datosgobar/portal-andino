#!/usr/bin/env python
# -*- coding: utf-8 -*-
import argparse
import subprocess
from os import path, geteuid, makedirs, remove, symlink, stat, chmod, environ, remove
from shutil import move

parser = argparse.ArgumentParser(description='Actulizar andino con docker.')

parser.add_argument('--branch', default='master')
parser.add_argument('--install_directory', default='/etc/andino/')

args = parser.parse_args()

REPOSITORY = "portal-andino"
CTL_FILE_NAME = "andino-ctl"
INSTALL_DIRECTORY = args.install_directory
USR_BIN_CRL = path.join("/usr/local/bin/", CTL_FILE_NAME)

COMPOSE_FILE_URL = "https://raw.githubusercontent.com/datosgobar/%s/%s/latest.yml" % (REPOSITORY, args.branch)
CTL_SCRIPT = "https://raw.githubusercontent.com/datosgobar/%s/%s/install/andino-ctl" % (REPOSITORY, args.branch)

UPGRADE_DB_COMMAND = "/etc/ckan_init.d/upgrade_db.sh"
REBUILD_SEARCH_COMMAND = "/etc/ckan_init.d/run_rebuild_search.sh"

directory = args.install_directory


def check_permissions():
    """
    Verifica el ID del usuario en Linux, debe ser 0 para el usuario root.
    :return:
    """
    if geteuid() != 0:
        print("[ ERROR ] Se necesitan permisso de root (sudo).")
        exit(1)


def check_installdir(base_path):
    """
    Verifica la existencia del directorio de instalación.
    Si existe, el script termina con error, de lo contrario crea el directorio para instalar la aplicación
    :param base_path: Directorio de instalación.
    :return:
    """
    if path.isdir(base_path):
        print("[ ERROR ] Se encontró instalción previa en %s, aborando." % base_path)
        exit(1)
    else:
        makedirs(base_path)


def ask(question):
    try:
        _ask = raw_input
    except NameError:
        _ask = input
    return _ask("%s\n" % question)


def check_docker():
    """
    Trata de acceder a docker para verificar que este disponible
    TODO: No mostrar el output
    :return:
    """
    subprocess.check_call([
        "docker",
        "ps"
    ])


def check_compose():
    """
    Trata de acceder a docker-compose para verificar que esta disponible
    TODO: No mostrar el output
    :return:
    """
    subprocess.check_call([
        "docker-compose",
        "--version",
    ])


def get_compose_file(base_path):
    """
    Descarga el nuevo archivo docker-compose.yml del repositorio.

    El hecho que se llame docker-compose.yml nos permite hacer uso de un archivo "docker-compose.override.yml"
    en caso de ser necesario. Ver https://docs.docker.com/compose/reference/overview/#specifying-multiple-compose-files
    :param base_path: Directorio de instalación
    :return:
    """
    compose_file_path = path.join(base_path, "docker-compose.yml")
    subprocess.check_call([
        "curl",
        COMPOSE_FILE_URL,
        "--output",
        compose_file_path
    ])
    return compose_file_path


def get_ctl_script_file(base_path):
    """
    Descarga el archivo para controlar la aplicación "andino-ctl".
    El mismo provee comandos para controlar y configurar la aplicación.

    Ademas crea un link a `/usr/local/bin/andino-ctl` para que el comando este disponible en el `PATH`
    :param base_path: Directorio de instalación
    :return:
    """
    ctl_script_path = path.join(base_path, CTL_FILE_NAME)
    if path.isfile(ctl_script_path):
        remove(ctl_script_path)

    call_subprocess([
        "curl",
        CTL_SCRIPT,
        "--fail",
        "--output",
        ctl_script_path
    ], directory)
    st = stat(ctl_script_path)
    chmod(ctl_script_path, st.st_mode | 0o0111)
    if not path.islink(USR_BIN_CRL):
        symlink(ctl_script_path, USR_BIN_CRL)

    return ctl_script_path


def call_subprocess(command, directory):
    """
    Comando para correr comando con la variable "OVERWRITE_APP_DIR".
    Esa variable es utilizada en el script andino-ctl para detectar
    un directorio de instalacion distinto al que se usa por defecto.

    :param command: (list) Comando a correr con subprocess
    :param directory: directorio de instalación
    :return:
    """
    my_env = environ.copy()
    my_env["OVERWRITE_APP_DIR"] = directory
    subprocess.check_call(command, env=my_env)


def fix_env_file(base_path):
    """
    Lee el archvo `.env` y detecta configuraciones faltantes
    :param directory: directorio de instalación
    :return:
    """
    env_file = ".env"
    env_file_path = path.join(base_path, env_file)
    nginx_var = "NGINX_HOST_PORT"
    datastore_var = "DATASTORE_HOST_PORT"
    maildomain_var = "maildomain"
    with open(env_file_path, "r+a") as env_f:
        content = env_f.read()
        if nginx_var not in content:
            env_f.write("%s=%s\n" % (nginx_var, "80"))
        if datastore_var not in content:
            env_f.write("%s=%s\n" % (datastore_var, "8800"))
        if maildomain_var not in content:
            maildomain = ask("Por favor, ingrese su dominio para envío de emails (e.g.: myportal.com.ar): ")
            real_maildomain = maildomain.strip()
            if not real_maildomain:
                print("Ningun valor fue ingresado, usando valor por defecto: localhost")
                real_maildomain = "localhost"
            env_f.write("%s=%s\n" % (maildomain_var, real_maildomain))


def backup(directory):
    """
    Corre comandos para crear backups de la base de datos y los archivos de la aplicación
    :param directory: directorio de instalación
    :return:
    """
    call_subprocess([USR_BIN_CRL, "backup_all_files"], directory)


def reload_application(directory):
    """
    Descarga los contenedores basandose en lo definido en el archivo `docker-compose.yml`.
    Luego levanta la aplicación con esos contenedores.
    :param directory: directorio de instalación
    :return:
    """
    call_subprocess([
        USR_BIN_CRL,
        "pull",
    ], directory)
    call_subprocess([
        USR_BIN_CRL,
        "up",
        "nginx",
    ], directory)


def check_previous_installation(base_path):
    """
    Verifica que el archivo de docker compose este presente.
    En case de llamarse "latest.yml" se lo renombra a "docker-compose.yml"

    :param base_path: directorio de instalación
    :return:
    """
    latest_file = "latest.yml"
    compose_file = "docker-compose.yml"

    latest_compose_file_path = path.join(base_path, latest_file)
    compose_file_path = path.join(base_path, compose_file)
    if path.isfile(latest_compose_file_path):
        print("[ INFO ] Moviendo latest.yml a docker-compose.yml")
        move(latest_compose_file_path, compose_file_path)
    if not path.isfile(compose_file_path):
        print("[ ERROR ] No se encontró el archivo %s en el directorio %s" % (compose_file, base_path))
        raise Exception("[ ERROR ] No se encontró una instalación.")


def post_update_commands(directory):
    """
    Corre los comandos post-update para actualizacion de la aplicación
    :param directory: directorio de instalación
    :return:
    """
    try:
        call_subprocess([
            USR_BIN_CRL,
            "post_update",
        ], directory)
    except subprocess.CalledProcessError as e:
        print("[ ERROR ] Error al correr el script 'andino-ctl post_update'")
        print(e)
        print("[ INFO ] Continuando")


def restart_apps(directory):
    """
    Reinicia la aplicación

    :param directory: directorio de instalación
    :return:
    """
    call_subprocess([
        USR_BIN_CRL,
        "restart",
    ], directory)


print("[ INFO ] Comprobando que docker esté instalado...")
check_docker()
print("[ INFO ] Comprobando que docker-compose este instalado...")
check_compose()
print("[ INFO ] Comprobando instalación previa...")
check_previous_installation(directory)
print("[ INFO ] Descargando archivos necesarios...")
compose_file_path = get_compose_file(directory)
ctl_script_path = get_ctl_script_file(directory)
fix_env_file(directory)
print("[ INFO ] Creando backups...")
backup(directory)
print("[ INFO ] Actualizando la aplicación")
reload_application(directory)
print("[ INFO ] Corriendo comandos post-instalación")
post_update_commands(directory)
print("[ INFO ] Reiniciando")
restart_apps(directory)
print("[ INFO ] Listo.")
