#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import subprocess
import time
from os import path, makedirs

from InstallationManager import InstallationManager


class Installer(InstallationManager):
    def check_previous_installation(self):
        install_directory = self.get_install_directory()
        if path.isdir(install_directory):
            self.logger.error("Se encontró instalación previa en %s, abortando." % install_directory)
            self.logger.error("El directorio no debería existir.")
            exit(1)
        else:
            makedirs(install_directory)

    def configure_env_file(self):
        env_file = ".env"
        env_file_path = path.join(self.get_install_directory(), env_file)
        andino_version = self.get_andino_version()
        with open(env_file_path, "w") as env_f:
            env_f.write("SITE_HOST=%s\n" % self.cfg.site_host)
            env_f.write("POSTGRES_USER=%s\n" % self.cfg.database_user)
            env_f.write("ANDINO_TAG=%s\n" % andino_version)
            env_f.write("POSTGRES_PASSWORD=%s\n" % self.cfg.database_password)
            env_f.write("NGINX_HOST_PORT=%s\n" % self.cfg.nginx_port)
            env_f.write("NGINX_HOST_SSL_PORT=%s\n" % self.cfg.nginx_ssl_port)
            env_f.write("DATASTORE_HOST_PORT=%s\n" % self.cfg.datastore_port)
            env_f.write("maildomain=%s\n" % self.cfg.site_host)
            env_f.write("NGINX_CONFIG_FILE=%s\n" % self.get_nginx_configuration())
            env_f.write("FILE_SIZE_LIMIT=%s\n" % self.cfg.file_size_limit)
            env_f.write("NGINX_EXTENDED_CACHE=%s\n" % ("yes" if self.cfg.nginx_extended_cache else "no"))
            if self.cfg.nginx_cache_max_size:
                env_f.write("NGINX_CACHE_MAX_SIZE=%s\n" % self.cfg.nginx_cache_max_size)
            if self.cfg.nginx_cache_inactive:
                env_f.write("NGINX_CACHE_INACTIVE=%s\n" % self.cfg.nginx_cache_inactive)
            env_f.write("TZ=%s\n" % self.cfg.timezone)
            env_f.write("THEME_VOLUME_SRC=%s\n" % self.cfg.theme_volume_src)

    def configure_application(self):
        cmd = "exec -T portal /etc/ckan_init.d/init.sh -e {0} -h {1} -p {2} -P {3} -d {4} -D {5}".format(
            self.cfg.error_email, self.cfg.site_host, self.cfg.database_user, self.cfg.database_password,
            self.cfg.datastore_user, self.cfg.datastore_password)
        self.run_compose_command(cmd)

    def run(self):
        self.logger.info("Comprobando permisos (sudo)...")
        self.check_permissions()
        self.logger.info("Comprobando que docker esté instalado...")
        self.check_docker()
        self.logger.info("Comprobando que docker-compose esté instalado...")
        self.check_compose()
        self.logger.info("Comprobando instalación previa...")
        self.check_previous_installation()

        # Download and install
        self.logger.info("Descargando archivos necesarios...")
        self.set_compose_files()
        self.logger.info("Escribiendo archivo de configuración del ambiente (.env) ...")
        self.configure_env_file()
        self.logger.info("Obteniendo imágenes de Docker")
        self.pull_application()
        # Configure
        self.logger.info("Iniciando la aplicación")
        self.load_application()
        self.logger.info("Esperando a que la base de datos este disponible...")
        time.sleep(10)
        self.logger.info("Configurando...")
        if self.cfg.nginx_extended_cache:
            self.logger.info("Configurando caché extendida de nginx")
            self.configure_nginx_extended_cache()
            self.include_necessary_nginx_configuration("extend_nginx.sh")
        if self.cfg.ssl_crt_path and self.cfg.ssl_key_path:
            self.logger.info("Copiando archivos del certificado de SSL")
            if path.isfile(self.cfg.ssl_crt_path) and path.isfile(self.cfg.ssl_key_path):
                self.persist_ssl_certificates()
            else:
                self.logger.error("No se pudo encontrar al menos uno de los archivos, "
                                  "por lo que no se realizará el copiado")
        self.logger.info("Corriendo la inicialización...")
        self.configure_application()
        self.logger.info("Actualizando archivo de configuración...")
        site_url = self.update_site_url_in_configuration_file()
        self.update_config_file_value("ckan.max_resource_size = {}".format(self.cfg.file_size_limit))
        self.logger.info("Configurando volumen...")
        if self.cfg.theme_volume_src != "/dev/null":
            subprocess.check_call("docker-compose -f latest.yml exec portal /usr/lib/ckan/default/bin/pip install "
                                  "-e /opt/theme",
                                  shell=True)
        self.logger.info("Reiniciando Nginx...")
        subprocess.check_call(["docker-compose", "-f", "latest.yml", "restart", "nginx"])
        self.restart_apps()
        self.logger.info("Esperando a que Nginx se reinicie...")
        self.ping_nginx_until_200_response_or_timeout(site_url)
        subprocess.check_call("docker-compose -f latest.yml exec portal supervisorctl restart all", shell=True)
        self.logger.info("Listo.")

    def parse_args(self):
        parser = argparse.ArgumentParser(description='Instalar andino con docker.')

        parser.add_argument('--error_email', required=True)
        parser.add_argument('--site_host', required=True)
        parser.add_argument('--database_user', required=True)
        parser.add_argument('--database_password', required=True)
        parser.add_argument('--datastore_user', required=True)
        parser.add_argument('--datastore_password', required=True)

        parser.add_argument('--andino_version')
        parser.add_argument('--nginx_port', default="80")
        parser.add_argument('--nginx_ssl_port', default="443")
        parser.add_argument('--datastore_port', default="8800")
        parser.add_argument('--branch', default='master')
        parser.add_argument('--install_directory', default='/etc/portal/')
        parser.add_argument('--file_size_limit', default='300')
        parser.add_argument('--nginx-extended-cache', action="store_true")
        parser.add_argument('--nginx-cache-max-size', default="")
        parser.add_argument('--nginx-cache-inactive', default="")
        parser.add_argument('--nginx_ssl', action="store_true")
        parser.add_argument('--ssl_key_path', default="")
        parser.add_argument('--ssl_crt_path', default="")
        parser.add_argument('--timezone', default="America/Argentina/Buenos_Aires")
        parser.add_argument('--use_local_compose_files', action="store_true")
        parser.add_argument('--theme_volume_src', default="/dev/null")

        return parser.parse_args()


if __name__ == "__main__":
    Installer().run()
