#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import os
import shutil
import subprocess
import time
import sys
from os import geteuid, path


class InstallationManager:

    def __init__(self):
        self.logger = self.build_logger()
        self.nginx_ssl_config_directory = '/etc/nginx/ssl'

    def run(self):
        pass

    def run_with_subprocess(self, command):
        subprocess.check_call(command, shell=True)

    def get_subprocess_output(self, command):
        return subprocess.check_output(command, shell=True).strip()

    def parse_args(self):
        pass

    def check_permissions(self):
        if geteuid() != 0:
            logging.error("Se necesitan permisos de root (sudo).")
            exit(1)

    def check_docker(self):
        self.run_with_subprocess("docker ps")

    def check_compose(self):
        self.run_with_subprocess("docker-compose --version")

    def download_file(self, file_path, download_url):
        self.run_with_subprocess("curl {0} --fail --output {1}".format(download_url, file_path))

    def get_compose_file(self, base_path, download_url, compose_file, use_local_compose_files):
        parent_directory = os.path.abspath(os.path.join(self.get_subprocess_output('pwd'), os.pardir))
        local_compose_file_path = path.join(parent_directory, compose_file)
        dest_compose_file_path = path.join(base_path, compose_file)
        if use_local_compose_files and os.path.isfile(local_compose_file_path):
            shutil.copyfile(local_compose_file_path, dest_compose_file_path)
        else:
            self.download_file(dest_compose_file_path, download_url)
        return dest_compose_file_path

    def get_stable_version_file(self, base_path, download_url):
        compose_file = "stable_version.yml"
        stable_version_path = path.join(base_path, compose_file)
        self.download_file(stable_version_path, download_url)
        return stable_version_path

    def get_andino_version(self, cfg, base_path, stable_version_url):
        if cfg.andino_version:
            andino_version = cfg.andino_version
        else:
            self.logger.info("Configurando versión estable de andino.")
            stable_version_path = self.get_stable_version_file(base_path, stable_version_url)
            with file(stable_version_path, "r") as f:
                content = f.read()
            andino_version = content.strip()
        self.logger.info("Usando versión '%s' de andino" % andino_version)
        return andino_version

    def configure_env_file(self, base_path, cfg, stable_version_url):
        pass

    def check_nginx_ssl_files_exist(self, cfg):
        return path.isfile(cfg.ssl_crt_path) and path.isfile(cfg.ssl_key_path)

    def get_nginx_configuration(self, cfg):
        if cfg.nginx_ssl:
            if self.check_nginx_ssl_files_exist(cfg):
                return "nginx_ssl.conf"
            self.logger.error("No se puede utilizar el archivo de configuración para SSL debido a que falta al menos "
                              "un archivo para el certificado. Se utilizará el default en su lugar.")
        return "nginx.conf"

    def pull_application(self, compose_path, dev_compose_path, theme_volume_src):
        extra_file_argument = "-f {}".format(dev_compose_path) if theme_volume_src else ""
        self.run_with_subprocess(
            "docker-compose -f {0} {1} pull --ignore-pull-failures".format(compose_path, extra_file_argument))

    def load_application(self, compose_path, dev_compose_path, theme_volume_src):
        extra_file_argument = "-f {}".format(dev_compose_path) if theme_volume_src else ""
        self.run_with_subprocess(
            "docker-compose -f {0} {1} up -d nginx".format(compose_path, extra_file_argument))

    def configure_application(self, compose_path):
        pass

    def restart_apps(self, compose_path):
        self.run_with_subprocess("docker compose -f {} restart".format(compose_path))

    def configure_nginx_extended_cache(self, compose_path):
        self.run_with_subprocess(
            "docker-compose -f {} exec -T portal /etc/ckan_init.d/update_conf.sh "  # TODO: usar update_config_file_value
            "andino.cache_clean_hook=http://nginx/meta/cache/purge".format(compose_path))
        self.run_with_subprocess(
            "docker-compose -f {} exec -T portal /etc/ckan_init.d/update_conf.sh "
            "andino.cache_clean_hook_method=PURGE".format(compose_path))

    def include_necessary_nginx_configuration(self, filename):
        self.run_with_subprocess("docker exec -d andino-nginx /etc/nginx/scripts/{}".format(filename))

    def persist_ssl_certificates(self, cfg):
        self.copy_file_to_container(
            cfg.ssl_key_path, "andino-nginx:{}/andino.key".format(self.nginx_ssl_config_directory))
        self.copy_file_to_container(
            cfg.ssl_key_path, "andino-nginx:{}/andino.crt".format(self.nginx_ssl_config_directory))

    def copy_file_to_container(self, src, dst):
        self.run_with_subprocess("docker cp {0} {1}".format(src, dst))

    def update_config_file_value(self, value, compose_path):
        if value:
            self.run_with_subprocess(
                "docker-compose -f {0} exec -T portal /etc/ckan_init.d/update_conf.sh {1}".format(compose_path, value))

    def ping_nginx_until_200_response_or_timeout(self, site_url):
        timeout = time.time() + 60 * 5  # límite de 5 minutos
        site_status_code = 0
        while site_status_code != "200":
            site_status_code = self.get_subprocess_output(
                'echo $(curl -k -s -o /dev/null -w "%{{http_code}}" {})'.format(site_url))
            print("Intentando comunicarse con: {0} - Código de respuesta: {1}".format(site_url, site_status_code))
            if time.time() > timeout:
                self.logger.warning("No fue posible reiniciar el contenedor de Nginx. "
                                    "Es posible que haya problemas de configuración.")
                break
            time.sleep(10 if site_status_code != "200" else 0)  # Si falla, esperamos 10 segundos para reintentarlo

    def build_logger(self):
        formatter = logging.Formatter('[ %(levelname)s ] %(message)s')
        ch = logging.StreamHandler(stream=sys.stdout)
        ch.setFormatter(formatter)
        logger = logging.getLogger(__file__)
        logger.setLevel(logging.DEBUG)
        logger.addHandler(ch)
        return logger
