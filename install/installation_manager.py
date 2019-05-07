#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import os
import shutil
import subprocess
import sys
import time
from abc import ABCMeta, abstractmethod
from os import chdir, getcwd, geteuid, path
from urlparse import urlparse


class InstallationManager(object):
    __metaclass__ = ABCMeta

    def __init__(self):
        self.base_url = "https://raw.githubusercontent.com/datosgobar/portal-andino"
        self.cfg = self.parse_args()
        self.compose_files = ['latest.yml', 'latest.dev.yml']
        self.logger = self.build_logger()
        self.site_url = ''
        self.stable_version_path = path.join(self.get_install_directory(), "stable_version.yml")

    def build_logger(self):
        formatter = logging.Formatter('[ %(levelname)s ] %(message)s')
        ch = logging.StreamHandler(stream=sys.stdout)
        ch.setFormatter(formatter)
        logger = logging.getLogger(__file__)
        logger.setLevel(logging.DEBUG)
        logger.addHandler(ch)
        return logger

    def run_with_subprocess(self, cmd):
        return subprocess.check_output(cmd, shell=True).strip()

    def run_compose_command(self, cmd):
        chdir(self.get_install_directory())
        output = self.run_with_subprocess("docker-compose {0} {1}".format(self.convert_compose_files_to_flags(), cmd))
        chdir(getcwd())
        return output

    def convert_compose_files_to_flags(self):
        return "%s%s" % ('-f ', ' -f '.join(self.compose_files))

    @abstractmethod
    def parse_args(self):
        return None

    def get_install_directory(self):
        return self.cfg.install_directory

    def check_permissions(self):
        if geteuid() != 0:
            logging.error("Se necesitan permisos de root (sudo).")
            exit(1)

    def check_docker(self):
        self.run_with_subprocess("docker ps")

    def check_compose(self):
        self.run_with_subprocess("docker-compose --version")

    def read_env_file_data(self, path):
        envconf = {}
        with open(path, "r") as env_f:
            for line in env_f.readlines():
                try:
                    key, value = line.split("=", 1)
                    envconf[key] = value.strip()
                except ValueError:
                    self.logger.warn("Ignorando linea '%s'" % line)
        return envconf

    @abstractmethod
    def check_previous_installation(self):
        pass

    def checkup(self):
        self.logger.info("Comprobando permisos (sudo)...")
        self.check_permissions()
        self.logger.info("Comprobando que docker esté instalado...")
        self.check_docker()
        self.logger.info("Comprobando que docker-compose esté instalado...")
        self.check_compose()
        self.logger.info("Comprobando instalación previa...")
        self.check_previous_installation()

    def prepare_necessary_files(self):
        self.logger.info("Descargando archivos necesarios...")
        self.set_compose_files()
        self.logger.info("Escribiendo archivo de configuración del ambiente (.env) ...")
        self.configure_env_file()

    def download_file(self, download_url, file_path):
        self.run_with_subprocess("curl {0} --fail --output {1}".format(download_url, file_path))

    def set_compose_files(self):
        parent_directory = os.path.abspath(os.path.join(self.run_with_subprocess('pwd'), os.pardir))
        for file in self.compose_files:
            local_compose_file_path = path.join(parent_directory, file)
            dest_compose_file_path = path.join(self.get_install_directory(), file)
            if self.cfg.use_local_compose_files and os.path.isfile(local_compose_file_path):
                shutil.copyfile(local_compose_file_path, dest_compose_file_path)
            else:
                download_url = path.join(self.base_url, self.cfg.branch, file)
                self.download_file(download_url, dest_compose_file_path)

    def get_andino_version(self):
        if self.cfg.andino_version:
            andino_version = self.cfg.andino_version
        else:
            self.logger.info("Configurando versión estable de andino...")
            self.download_stable_version_file()
            with file(self.stable_version_path, "r") as f:
                content = f.read()
            andino_version = content.strip()
        self.logger.info("Usando versión '%s' de andino" % andino_version)
        return andino_version

    def download_stable_version_file(self):
        stable_version_file_name = "stable_version.txt"
        stable_version_url = path.join(self.base_url, self.cfg.branch, "install", stable_version_file_name)
        self.download_file(stable_version_url, self.stable_version_path)

    @abstractmethod
    def configure_env_file(self):
        pass

    def get_nginx_configuration(self):
        if self.cfg.nginx_ssl:
            if self.check_nginx_ssl_files_exist():
                return "nginx_ssl.conf"
            self.logger.warning("No se puede utilizar el archivo de configuración para SSL debido a que falta al menos "
                                "un archivo para el certificado. Se utilizará el default en su lugar.")
        return "nginx.conf"

    def check_nginx_ssl_files_exist(self):
        return path.isfile(self.cfg.ssl_crt_path) and path.isfile(self.cfg.ssl_key_path)

    def pull_application(self):
        self.run_compose_command("pull --ignore-pull-failures")

    def load_application(self):
        self.run_compose_command("up -d nginx")

    @abstractmethod
    def prepare_application(self):
        pass

    def configure_nginx(self):
        self.logger.info("Configurando Nginx...")
        if self.cfg.nginx_extended_cache:
            self.logger.info("Configurando caché extendida de nginx...")
            self.configure_nginx_extended_cache()
            self.include_necessary_nginx_configuration("extend_nginx.sh")
        if self.cfg.ssl_crt_path and self.cfg.ssl_key_path:
            self.logger.info("Copiando archivos del certificado de SSL...")
            if path.isfile(self.cfg.ssl_crt_path) and path.isfile(self.cfg.ssl_key_path):
                self.persist_ssl_certificates()
            else:
                self.logger.warning("No se pudo encontrar al menos uno de los archivos, "
                                    "por lo que no se realizará el copiado")

    @abstractmethod
    def run_configuration_scripts(self):
        pass

    def configure_theme_volume(self):
        self.logger.info("Configurando volumen...")
        if self.cfg.theme_volume_src != "/dev/null":
            self.run_compose_command("exec portal /usr/lib/ckan/default/bin/pip install -e /opt/theme")

    def configure_nginx_extended_cache(self):
        self.update_config_file_value("andino.cache_clean_hook=http://nginx/meta/cache/purge")
        self.update_config_file_value("andino.cache_clean_hook_method=PURGE")

    def update_config_file_value(self, value):
        if value:
            self.run_compose_command("exec portal /etc/ckan_init.d/update_conf.sh '{}'".format(value))

    def include_necessary_nginx_configuration(self, filename):
        self.run_compose_command("exec nginx /etc/nginx/scripts/{}".format(filename))

    def persist_ssl_certificates(self):
        nginx_ssl_config_directory = '/etc/nginx/ssl'
        self.copy_file_to_container(
            self.cfg.ssl_key_path, "andino-nginx:{}/andino.key".format(nginx_ssl_config_directory))
        self.copy_file_to_container(
            self.cfg.ssl_crt_path, "andino-nginx:{}/andino.crt".format(nginx_ssl_config_directory))

    def copy_file_to_container(self, src, dst):
        self.run_with_subprocess("docker cp -L {0} {1}".format(src, dst))

    def update_configuration_file(self):
        self.logger.info("Actualizando archivo de configuración...")
        if self.cfg.file_size_limit:
            self.update_config_file_value("ckan.max_resource_size = {}".format(self.cfg.file_size_limit))
        self.update_site_url_in_configuration_file()

    def update_site_url_in_configuration_file(self):
        env_file = ".env"
        env_file_path = path.join(self.get_install_directory(), env_file)
        envconf = self.read_env_file_data(env_file_path)
        site_host = "SITE_HOST"
        nginx_var = "NGINX_HOST_PORT"
        nginx_ssl_var = "NGINX_HOST_SSL_PORT"
        nginx_config_file = "NGINX_CONFIG_FILE"

        # Se modifica el campo "ckan.site_url" modificando el protocolo para que quede HTTP o HTTPS según corresponda
        current_url = self.get_config_file_field('ckan.site_url')
        host_name = envconf.pop(site_host, urlparse(current_url).hostname)
        config_file_in_use = envconf.pop(nginx_config_file)

        port = ''
        if config_file_in_use == 'nginx_ssl.conf' and envconf.get(nginx_ssl_var) != '443':
            port = ':{}'.format(envconf.pop(nginx_ssl_var, ''))
        elif config_file_in_use == 'nginx.conf' and envconf.get(nginx_var) != '80':
            port = ':{}'.format(envconf.pop(nginx_var, ''))
        new_url = "http{0}://{1}{2}".format('s' if config_file_in_use == 'nginx_ssl.conf' else '', host_name, port)

        if current_url != new_url:
            self.logger.info("Actualizando site_url...")
            self.run_compose_command("exec -T portal /etc/ckan_init.d/change_site_url.sh {}".format(new_url))
        self.site_url = new_url

    def get_config_file_field(self, name):
        cmd = 'exec -T portal grep -E "^{}[[:space:]]*=[[:space:]]*" ' \
              '/etc/ckan/default/production.ini | tr -d [[:space:]]'.format(name)
        current_url = self.run_compose_command(cmd)
        return current_url.replace(name, '')[1:]  # guardamos sólo la url, ignoramos el símbolo '='

    def restart_apps(self):
        self.logger.info("Reiniciando la aplicación...")
        self.run_compose_command("restart")
        self.logger.info("Esperando a que Nginx inicie...")
        self.ping_nginx_until_200_response_or_timeout()
        self.run_compose_command("exec portal supervisorctl restart all")
        self.logger.info("Listo.")

    def ping_nginx_until_200_response_or_timeout(self):
        timeout = time.time() + 60 * 5  # límite de 5 minutos
        site_status_code = 0
        while site_status_code != "200":
            site_status_code = self.run_with_subprocess(
                'echo $(curl -k -s -o /dev/null -w "%{{http_code}}" {})'.format(self.site_url))
            print("Intentando comunicarse con: {0} - Código de respuesta: {1}".format(self.site_url, site_status_code))
            if time.time() > timeout:
                self.logger.warning("No fue posible reiniciar el contenedor de Nginx. "
                                    "Es posible que haya problemas de configuración.")
                break
            time.sleep(10 if site_status_code != "200" else 0)  # Si falla, esperamos 10 segundos para reintentarlo

    @abstractmethod
    def run(self):
        pass
