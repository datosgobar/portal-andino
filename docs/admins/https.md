# Configuración HTTPS

La forma más sencilla de configurar HTTPS para nuestro servidor **andino** es instalando nginx en el servidor que sirve de
*host* para la aplicación.
Tambien debemos contar ya con los certificados `.key` y `.crt` para nuestra aplicación.
Cómo obtenerlos esta fuera del "scope" de esta documentación.

## Configuración de la aplicación

Primero, debemos asegurarnos que nuestra aplicación no este haciendo uso del puerto 80 del servidor, que es el comportamiendo
por defecto.

Si aún no instalamos nuestra aplicación, debemos correr el script `install.py` como lo hacemos normalmente,
pero con el parámetro `--nginx_port 127.0.0.1:8000`:

```
sudo python install.py ...opciones normales... --nginx_port 127.0.0.1:8000

```

Esto hará que nuestra aplicación sólamente sea accesible desde el servidor y en el puerto **8000**.


Si nuestra aplicación ya está instalada, debemos modificar un archivo y *recrear* el contenedor de nginx.
Debemos ir al directorio donde se instaló la aplicación (`/etc/portal`) y editar el archivo `.env`.

```
cd /etc/portal
vim .env
```

En el mismo habrá una línea parecida a esta:

```
NGINX_HOST_PORT=80
```

Debemos cambiarla para que sea:

```
NGINX_HOST_PORT=127.0.0.1:8000
```

Luego debemos *recrear* el contenedor de nginx:

`docker-compose -f latest.yml up -d nginx`

## Configuracion de nginx

Ahora que nuestra aplicacón es accesible internamente, debemos instalar y configurar nginx _en el servidor que funciona como host_ para que apunte a la misma
*y redireccione* a HTTTPS de ser necesario.

Para eso, primero instalamos `nginx` según nuestro sistema operativo:

- Ubuntu: `sudo apt-get install nginx`

Primero creamos una clave **Diffie-Hellman** para más seguridad (ver [este artículo](https://medium.com/@mvuksano/how-to-properly-configure-your-nginx-for-tls-564651438fe0) para mas información).

```
sudo mkdir /etc/nginx/ssl/
sudo openssl dhparam 2048 -out /etc/nginx/ssl/andino_dhparam.pem
```

Luego debemos agregar la configuracion de `nginx` para que haga uso de nuestros certificados.

Aquí asumiremos que nuestro sitio es `miandino.gob.ar` y los certificados estan en `/etc/nginx/ssl/andino.crt` y `/etc/nginx/ssl/andino.key`.
La configuracion la agregaremos en `/etc/nginx/sites-available/001-andino.conf`

```
server_tokens off;

add_header X-Frame-Options SAMEORIGIN;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";

upstream wsgi_andino {
  # fail_timeout=0 means we always retry an upstream even if it failed
  # to return a good HTTP response (in case the gunicorn master nukes a
  # single worker for timing out).

  server 127.0.0.1:8000 fail_timeout=0;
}

# redirect all http traffic to https
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name miandino.gob.ar;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name miandino.gob.ar;

  ssl_certificate /etc/nginx/ssl/andino.crt;
  ssl_certificate_key /etc/nginx/ssl/andino.key;

  ssl_session_cache shared:SSL:50m;
  ssl_session_timeout 1d;
  ssl_session_tickets off;

  ssl_dhparam /etc/nginx/ssl/andino_dhparam.pem;

  ssl_prefer_server_ciphers on;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';

  resolver 8.8.8.8 8.8.4.4;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_trusted_certificate /etc/nginx/ssl/andino.crt;

  add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

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
}
```


Activamos el sitio

```
sudo rm /etc/nginx/sites-enabled/default -rf
sudo ln -s /etc/nginx/sites-available/001-andino.conf /etc/nginx/sites-enabled/001-andino.conf

sudo systemctl restart nginx
```

Finalmente deberiamos poder acceder a nuestro sitio en http://miandino.gob.ar:80 y ser redireccionados a https://miandino.gob.ar:443.
El explorador *no debería* mostrarnos ninguna advertencia si los certificados son correctos.
