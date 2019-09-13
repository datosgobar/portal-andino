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

    def configure_env_file(self):
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
        envconf = self.read_env_file_data()

        # Backup current config
        env_file = ".env"
        env_file_path = path.join(self.get_install_directory(), env_file)
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
            entered_site_host = ""
            while not entered_site_host:
                entered_site_host = self.ask("Por favor, ingrese un nombre de dominio (e.g.: myportal.com.ar):").strip()
            envconf[site_host] = entered_site_host

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

    def check_nginx_ssl_files_exist(self):
        if super(Updater, self).check_nginx_ssl_files_exist():
            return True
        else:
            cmd = "docker exec andino-nginx bash -c 'if [[ -f \"$NGINX_SSL_CONFIG_DATA/{}\" ]]  ;" \
                  " then echo \"Y\" ; else echo \"N\" ; fi'"
            return self.run_with_subprocess(cmd.format('andino.key')) == 'Y' and \
                   self.run_with_subprocess(cmd.format("andino.crt")) == 'Y'

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

    def run_configuration_scripts(self):
        self.logger.info("Corriendo comandos post-instalación...")
        current_plugins = self.get_config_file_field("ckan.plugins")
        plugins_to_remove = "datajson_harvest datajson harvest ckan_harvester "
        current_plugins = current_plugins.replace(plugins_to_remove, '')
        try:
            self.run_compose_command("exec -T portal bash /etc/ckan_init.d/run_updates.sh")
        except subprocess.CalledProcessError as e:
            self.logger.exception("Error al correr el script 'run_updates.sh'.\n{}".format(e))
        self.update_config_file_value("ckan.plugins = {}".format(current_plugins))
        self.restart_apache()
        try:
            self.run_compose_command("exec -T portal bash /etc/ckan_init.d/update_data_json_and_catalog_xlsx.sh")
        except subprocess.CalledProcessError as e:
            self.logger.exception("Error al correr el script 'update_data_json_and_catalog_xlsx.sh'.\n{}".format(e))
        self.run_compose_command("exec -T portal /etc/ckan_init.d/upgrade_db.sh")
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

    def prepare_application(self):
        self.logger.info("Revisando estado de los servicios...")
        state = self.run_with_subprocess("docker ps")
        self.logger.info(state)
        state = self.run_compose_command("ps")
        self.logger.info(state)
        self.logger.info("Guardando base de datos...")
        self.backup_database()
        self.logger.info("Actualizando la aplicación...")
        self.logger.info("Descargando nuevas imagenes...")
        self.pull_application()
        self.logger.info("Reiniciando la aplicación...")
        self.load_application()

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

    def run(self):
        self.checkup()
        self.prepare_necessary_files()
        self.prepare_application()
        self.correct_ckan_public_files_permissions()
        crontab_content = self.find_cron_jobs()
        self.build_whole_site_url()
        self.configure_nginx()
        self.restart_apps()
        self.ping_nginx_until_app_responds_or_timeout()
        self.run_configuration_scripts()
        self.configure_theme_volume()
        if crontab_content:
            self.restore_cron_jobs(crontab_content)
        self.update_configuration_file()
        self.apply_additional_configurations()
        self.restart_apps()
        self.ping_nginx_until_app_responds_or_timeout()
        self.restart_workers()


if __name__ == "__main__":
    Updater().run()
