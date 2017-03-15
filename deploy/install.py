#!/usr/bin/env python
import argparse, tempfile, subprocess, time

from os import path

parser = argparse.ArgumentParser(description='Instalar andino con docker.')

parser.add_argument('--datapusherhost', required=True)
parser.add_argument('--error_email', required=True)
parser.add_argument('--site_host', required=True)
parser.add_argument('--database_user', required=True)
parser.add_argument('--database_password', required=True)
parser.add_argument('--datastore_user', required=True)
parser.add_argument('--datastore_password', required=True)

args = parser.parse_args()

COMPOSE_FILE_URL = "https://raw.githubusercontent.com/datosgobar/portal-andino/development/lasted.yml"

print("Checking docker is available...")

subprocess.check_call([
    "docker",
    "ps"
])

print("Checking docker-compose is available")

subprocess.check_call([
    "docker-compose",
    "--version",
])

print("Downloading required files...")

directory = tempfile.mkdtemp()  # Maybe should not be a tmp directory
compose_file = "lasted.yml"
env_file = ".env"
compose_file_path = path.join(directory, compose_file)
env_file_path = path.join(directory, env_file)

subprocess.check_call([
    "curl",
    COMPOSE_FILE_URL,
    "--output",
    compose_file_path
])

print("Writing environment file...")

with open(env_file_path, "w") as env_f:
    env_f.write("POSTGRES_USER=%s\n" % args.database_user)
    env_f.write("POSTGRES_PASSWORD=%s\n" % args.database_password)
    env_f.write("CKAN_HOST=andino\n")


print("Starting up site")
subprocess.check_call([
    "docker-compose",
    "-f",
    compose_file_path,
    "up",
    "-d",
    "nginx",
])

print("waiting a few seconds for db start up...")

time.sleep(10)

subprocess.check_call([
    "docker",
    "exec",
    "andino",
    "/etc/ckan_init.d/init.sh",
    "-u", args.datapusherhost,
    "-e", args.error_email,
    "-h", args.site_host,
    "-p", args.database_user,
    "-P", args.database_password,
    "-d", args.datastore_user,
    "-D", args.datastore_password,
])
