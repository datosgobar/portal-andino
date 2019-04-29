#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import shutil
import subprocess
import time
from os import path

from installation_manager import InstallationManager


class Updater(InstallationManager):
    def ask(self, question):
        try:
            _ask = raw_input
        except NameError:
            _ask = input
        return _ask("%s\n" % question)

    def check_previous_installation(self):
        compose_file = "latest.yml"
        compose_file_path = path.join(self.get_install_directory(), compose_file)
        if not path.isfile(compose_file_path):
            self.logger.error("No se encontró el archivo %s en el directorio actual" % compose_file)
            self.logger.error("Por favor, corra este comando en el mismo directorio donde instaló la aplicación")
            raise Exception("[ ERROR ] No se encontró una instalación.")

    def check_nginx_ssl_files_exist(self):
        if super(Updater, self).check_nginx_ssl_files_exist():
            return True
        else:
            # Chequeo si los archivos ya existen en el contenedor de Nginx, para no tener que pasarlos en cada update
            cmd = "exec nginx bash -c 'if [[ -f \"$NGINX_SSL_CONFIG_DATA/{}\" ]]  ;" \
                  " then echo \"Y\" ; else echo \"N\" ; fi'"
            return self.run_compose_command(cmd.format('andino.key')) == 'Y' and \
                   self.run_compose_command(cmd.format("andino.crt")) == 'Y'

    def configure_env_file(self):
        env_file = ".env"
        env_file_path = path.join(self.get_install_directory(), env_file)
        site_host = "SITE_HOST"
        nginx_config_file = "NGINX_CONFIG_FILE"
        nginx_extended_cache = "NGINX_EXTENDED_CACHE"
        nginx_cache_max_size = "NGINX_CACHE_MAX_SIZE"
        nginx_cache_inactive = "NGINX_CACHE_INACTIVE"
        nginx_var = "NGINX_HOST_PORT"
        nginx_ssl_var = "NGINX_HOST_SSL_PORT"
        file_size_limit = "FILE_SIZE_LIMIT"
        timezone = "TIMEZONE"
        datastore_port = "DATASTORE_HOST_PORT"
        maildomain = "maildomain"

        # Get current variables
        envconf = self.read_env_file_data(env_file_path)

        # Backup current config
        self.generate_env_file_backup(env_file_path)

        # Write new config
        envconf["ANDINO_TAG"] = self.get_andino_version()
        envconf[nginx_config_file] = self.get_nginx_configuration()
        envconf[nginx_extended_cache] = "yes" if self.cfg.nginx_extended_cache else "no"

        envconf[nginx_cache_max_size] = \
            self.cfg.nginx_cache_max_size if self.cfg.nginx_cache_max_size else envconf.get(nginx_cache_max_size, '')

        envconf[nginx_cache_inactive] = \
            self.cfg.nginx_cache_inactive if self.cfg.nginx_cache_inactive else envconf.get(nginx_cache_inactive, '')

        if self.cfg.site_host:
            envconf[site_host] = self.cfg.site_host
        elif not envconf.get(site_host, ''):
            envconf[site_host] = "andino_nginx"

        if self.cfg.nginx_port:
            envconf[nginx_var] = self.cfg.nginx_port
        elif not envconf.get(nginx_var, ''):
            envconf[nginx_var] = "80"

        if self.cfg.nginx_ssl_port:
            envconf[nginx_ssl_var] = self.cfg.nginx_ssl_port
        elif not envconf.get(nginx_ssl_var, ''):
            envconf[nginx_ssl_var] = "443"

        if self.cfg.datastore_port:
            envconf[datastore_port] = self.cfg.datastore_port
        elif not envconf.get(datastore_port, ''):
            envconf[datastore_port] = "8800"

        if not envconf[maildomain]:
            entered_maildomain = self.ask(
                "Por favor, ingrese su dominio para envío de emails (e.g.: myportal.com.ar): ").strip()
            if not entered_maildomain:
                print("Ningún valor fue ingresado. Usando valor por defecto: localhost")
                entered_maildomain = "localhost"
            envconf[maildomain] = entered_maildomain

        if self.cfg.file_size_limit:
            envconf[file_size_limit] = self.cfg.file_size_limit
        elif not envconf.get(file_size_limit, ''):
            envconf[file_size_limit] = "300"

        if self.cfg.timezone:
            envconf[timezone] = self.cfg.timezone
        elif not envconf.get(timezone, ''):
            envconf[timezone] = "America/Argentina/Buenos_Aires"

        envconf["THEME_VOLUME_SRC"] = self.cfg.theme_volume_src

        with open(env_file_path, "w") as env_f:
            for key in envconf.keys():
                env_f.write("%s=%s\n" % (key, envconf[key]))

    def generate_env_file_backup(self, env_file_path):
        datetime_var = time.strftime("__%d_%m_%y-%H-%M")
        backup_env_file = "%s%s" % (path.basename(env_file_path), datetime_var)
        backup_env_file_path = path.join(self.get_install_directory(), backup_env_file)
        shutil.move(env_file_path, backup_env_file_path)

    def backup_database(self):
        output = self.run_compose_command("exec db bash -lc env PGPASSWORD=$POSTGRES_PASSWORD pg_dump "
                                          "--format=custom -U $POSTGRES_USER $POSTGRES_DB")
        dump_name = "%s-ckan.dump" % time.strftime("%d:%m:%Y:%H:%M:%S")
        dump = path.join(self.get_install_directory(), dump_name)
        with open(dump, "wb") as a_file:
            a_file.write(output)

    def configure_application(self):
        current_plugins = "stats text_view image_view recline_view hierarchy_display hierarchy_form dcat " \
                          "structured_data gobar_theme datastore datapusher seriestiempoarexplorer googleanalytics"
        try:
            self.run_compose_command("exec -T portal bash /etc/ckan_init.d/run_updates.sh")
        except subprocess.CalledProcessError as e:
            self.logger.error("Error al correr el script 'run_updates.sh'")
            self.logger.error(e)
        try:
            self.run_compose_command("exec -T portal bash /etc/ckan_init.d/update_data_json_and_catalog_xlsx.sh")
        except subprocess.CalledProcessError as e:
            self.logger.error("Error al correr el script 'update_data_json_and_catalog_xlsx.sh'")
            self.logger.error(e)
        try:
            self.run_compose_command("exec -T portal /etc/ckan_init.d/upgrade_db.sh")
        finally:
            self.update_config_file_value("ckan.plugins = {}".format(current_plugins))
        self.run_compose_command("exec -T portal /etc/ckan_init.d/run_rebuild_search.sh")

    def find_cron_jobs(self):
        try:
            crontab_content = self.run_compose_command("exec portal crontab -u www-data -l")
            self.logger.info("Tareas croneadas encontradas a guardar: {}".format(crontab_content))
        except subprocess.CalledProcessError:
            # No hay cronjobs para guardar
            crontab_content = ""
        return crontab_content

    def restore_cron_jobs(self, crontab_content):
        try:
            self.run_compose_command("bash -c 'echo \"{}\" | sudo crontab -u www-data -'".format(crontab_content))
        except subprocess.CalledProcessError:
            # Error durante un deploy; se lo ignora
            pass

    def run(self):
        self.logger.info("Comprobando permisos (sudo)...")
        self.check_permissions()
        self.logger.info("Comprobando que docker esté instalado...")
        self.check_docker()
        self.logger.info("Comprobando que docker-compose esté instalado...")
        self.check_compose()
        self.logger.info("Comprobando instalación previa...")
        self.check_previous_installation()

        # Download and update
        self.logger.info("Descargando archivos necesarios...")
        self.set_compose_files()
        self.logger.info("Escribiendo archivo de configuración del ambiente (.env) ...")
        self.configure_env_file()
        crontab_content = self.find_cron_jobs()
        self.logger.info("Guardando base de datos...")
        self.backup_database()
        self.logger.info("Actualizando la aplicación")
        self.logger.info("Descargando nuevas imagenes...")
        self.pull_application()
        # Configure
        self.logger.info("Reiniciando la aplicación")
        self.load_application()
        if self.cfg.nginx_extended_cache:
            self.logger.info("Configurando caché extendida de nginx")
            self.configure_nginx_extended_cache()
            self.include_necessary_nginx_configuration("extend_nginx.sh")
        if self.cfg.ssl_crt_path and self.cfg.ssl_key_path:
            self.logger.info("Copiando archivos del certificado de SSL")
            if path.isfile(self.cfg.ssl_crt_path) and path.isfile(self.cfg.ssl_key_path):
                self.persist_ssl_certificates()
            else:
                self.logger.error("No se pudo encontrar uno de los archivos, por lo que no se realizará el copiado")
        self.logger.info("Corriendo comandos post-instalación")
        self.configure_application()
        if crontab_content:
            self.restore_cron_jobs(crontab_content)
        site_url = self.update_site_url_in_configuration_file()
        if self.cfg.file_size_limit:
            self.update_config_file_value("ckan.max_resource_size = {}".format(self.cfg.file_size_limit))
        if self.cfg.theme_volume_src != "/dev/null":
            self.run_compose_command("exec portal /usr/lib/ckan/default/bin/pip install -e /opt/theme")
        self.logger.info("Reiniciando")
        self.restart_apps()
        self.logger.info("Esperando a que Nginx inicie...")
        self.ping_nginx_until_200_response_or_timeout(site_url)
        self.run_compose_command("exec portal supervisorctl restart all")
        self.logger.info("Listo.")

    def parse_args(self):
        parser = argparse.ArgumentParser(description='Actualizar andino.')

        parser.add_argument('--branch', default='master')
        parser.add_argument('--install_directory', default='/etc/portal/')
        parser.add_argument('--andino_version')
        parser.add_argument('--site_host', default="")  # Sin default para evitar overrides si ya existe un valor
        parser.add_argument('--nginx_port', default="")  # Sin default para evitar overrides si ya existe un valor
        parser.add_argument('--nginx_ssl_port', default="")  # Sin default para evitar overrides si ya existe un valor
        parser.add_argument('--datastore_port', default="")  # Sin default para evitar overrides si ya existe un valor
        parser.add_argument('--file_size_limit', default="")  # Sin default para evitar overrides si ya existe un valor
        parser.add_argument('--timezone', default="")  # Sin default para evitar overrides si ya existe un valor
        parser.add_argument('--nginx-extended-cache', action="store_true")
        parser.add_argument('--nginx-cache-max-size', default="")
        parser.add_argument('--nginx-cache-inactive', default="")
        parser.add_argument('--nginx_ssl', action="store_true")
        parser.add_argument('--ssl_key_path', default="")
        parser.add_argument('--ssl_crt_path', default="")
        parser.add_argument('--use_local_compose_files', action="store_true")
        parser.add_argument('--theme_volume_src', default="/dev/null")

        return parser.parse_args()


if __name__ == "__main__":
    Updater().run()
