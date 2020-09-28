# Tests

Para correr los tests de la aplicación, se deben levantar todos los servicios, y luego inicializar la configuración de test.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Indice

- [Tests de Ckan](#tests-de-ckan)
- [Levantar instancias de prueba de Andino en los distros soportados con vagrant](#levantar-instancias-de-prueba-de-andino-en-los-distros-soportados-con-vagrant)
    - [RHEL](#rhel)
- [Probar la instalación con SSL en Vagrant (Instalando nginx)](#probar-la-instalacion-con-ssl-en-vagrant-instalando-nginx)
    - [Instalación de andino](#instalacion-de-andino)
    - [Instalar y configurar nginx](#instalar-y-configurar-nginx)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Tests de Ckan
    $ docker-compose -f dev.yml up --build -d portal
    $ docker exec andino bash /etc/ckan_init.d/tests/install_solr4.sh    
    $ docker exec andino bash /etc/ckan_init.d/tests/install_nodejs.sh    
    $ docker exec andino bash -c 'su -c "bash /etc/ckan_init.d/tests/run_all_tests.sh" -l $USER'
    
    
## Levantar instancias de prueba de Andino en los distros soportados con vagrant

Existe un archivo de bash en el directorio `vagrant/`, `install_with_vagrant.sh`, el cual se puede ejecutar para instalar 
Andino en una de las cuatro distros soportadas (Ubuntu, Debian, RHEL y CentOS). Al ejecutarlo, el script solicitará cuál 
distro deberá utilizar y, luego de recibirla, realizará la instalación de Andino junto con una posterior actualización, 
ejecutando todos los tests existentes.

### RHEL

Para poder levantar correctamente la instancia en RHEL, es necesario proveer en un `.env` dentro del directorio 
`vagrant/rhel/` las credenciales de un 
[usuario desarrollador registrado de RHEL](https://developers.redhat.com/products/rhel/download) de la siguiente forma:
```
user=nombre_del_usuario
password=contraseña
```
Creando el usuario, no es necesario descargar la iso de RHEL.

El usuario desarrollador es necesario debido a que se lo necesita para utilizar el subscription manager. 


## Probar la instalación con SSL en Vagrant (Instalando nginx)

### Instalación de andino

Primero, debemos evitar instalar la aplicación en vagrant, ya que pasaremos un parámetro mas.
Para eso, modificamos el `Vagrantfile` cambiando las líneas:

```diff
-INSTALL_APP = true
-UPDATE_APP = !INSTALL_APP
+INSTALL_APP = false
+UPDATE_APP = false
```

Y luego levantar la VM con `vagrant up`.

Luego entramos a la aplicación y corremos el siguiente comando:

```
sudo -E python ./install.py --error_email admin@example.com --site_host 192.168.23.10 --database_user db_user --database_password db_pass --datastore_user data_db_user --datastore_password data_db_pass --nginx_port 127.0.0.1:8000
```

Esto instalará la aplicación, pero solo la hará accesible desde `localhost:8000`.

### Instalar y configurar nginx

Luego, instalamos `nginx` en el host `sudo apt install nginx`.

Generamos los certificados locales:

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/andino.key -out /etc/nginx/ssl/andino.crt
```

Creamos la configuracion de nginx _(no apta para producción)_ en `/etc/nginx/sites-available/001-andino.conf`:

```
upstream wsgi_andino {
  # fail_timeout=0 means we always retry an upstream even if it failed
  # to return a good HTTP response (in case the gunicorn master nukes a
  # single worker for timing out).

  server 127.0.0.1:8000 fail_timeout=0;
}

server {
    listen 80;
    #example: server_name www.datos.gob.ar datos.gob.ar;
    server_name dev.andino.gob.ar dev.andino.gob.ar;
    return 301 https://$host$request_uri;
}
server {
    listen   443;
    server_name dev.andino.gob.ar;

    ssl    on;
    ssl_certificate   /etc/nginx/ssl/andino.crt;
    ssl_certificate_key    /etc/nginx/ssl/andino.key;

    client_max_body_size 4G;
    keepalive_timeout 5;
    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Protocol https;
        proxy_redirect off;

        if (!-f $request_filename) {
            proxy_pass http://wsgi_andino;
            break;
        }
    }
    gzip on;
    gzip_disable "msie6";
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

}
```

Activamos el sitio:

```
sudo rm /etc/nginx/sites-enabled/default -rf
sudo ln -s /etc/nginx/sites-available/001-andino.conf /etc/nginx/sites-enabled/001-andino.conf

sudo systemctl restart nginx
```

Finalmente, accedemos al sitio en http://192.168.23.10:80, y el mismo nos debería redireccionar a la versión *https*.
El explorador nos mostrará una advertencia sobre el sitio, ya que no podrá validar los certificados.

