# Mantenimiento
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Indice

- [Exploración de la instancia de andino](#exploracion-de-la-instancia-de-andino)
    - [¿Qué está corriendo docker?](#que-esta-corriendo-docker)
    - [Utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latestyml-en-los-comandos-de-docker-compose)
    - [Ingresar al contendor principal de andino](#ingresar-al-contendor-principal-de-andino)
    - [Listar todas las `Propiedades` de cada contenedor](#listar-todas-las-propiedades-de-cada-contenedor)
- [Administración de usuarios](#administracion-de-usuarios)
    - [Crear un usuario ADMIN](#crear-un-usuario-admin)
    - [Listar mis usuarios](#listar-mis-usuarios)
    - [Ver los datos de un usuario](#ver-los-datos-de-un-usuario)
    - [Crear un nuevo usuario](#crear-un-nuevo-usuario)
    - [Crear un nuevo usuario extendido](#crear-un-nuevo-usuario-extendido)
    - [Eliminar un usuario](#eliminar-un-usuario)
    - [Cambiar password de un usuario](#cambiar-password-de-un-usuario)
    - [Usuario administrador de CKAN](#usuario-administrador-de-ckan)
- [Configuraciones de andino](#configuraciones-de-andino)
    - [Modificar el archivo de configuración](#modificar-el-archivo-de-configuracion)
    - [Cambiar la configuración del SMTP](#cambiar-la-configuracion-del-smtp)
    - [Cambiar el remitente de los correos electrónicos que envía Andino](#cambiar-el-remitente-de-los-correos-electronicos-que-envia-andino)
    - [Cambiar el id del container de Google Tag Manager](#cambiar-el-id-del-container-de-google-tag-manager)
    - [Google Tag Manager](#google-tag-manager)
    - [Cambiar el id del tag de Google Analytics](#cambiar-el-id-del-tag-de-google-analytics)
    - [Indexar datasets con Google Dataset Search](#indexar-datasets-con-google-dataset-search)
    - [Deshabilitar la URL `/catalog.xlsx`](#deshabilitar-la-url-catalogxlsx)
    - [Configuración de la llamada de invalidación de caché](#configuracion-de-la-llamada-de-invalidaci%C3%B3n-de-cache)
    - [Caché externa](#cache-externa)
    - [Especificar las licencias a utilizar](#especificar-las-licencias-a-utilizar)
    - [Configuración de CORS](#configuracion-de-cors)
    - [Configuración del explorador de series de tiempo](#configuracion-del-explorador-de-series-de-tiempo)
    - [Reemplazar Datapusher por el plugin ckanext-xloader](#reemplazar-datapusher-por-el-plugin-ckanext-xloader)
- [Acceso a los datos de andino](#acceso-a-los-datos-de-andino)
    - [Encontrar los volúmenes de mi andino dentro del filesystem del host](#encontrar-los-volumenes-de-mi-andino-dentro-del-filesystem-del-host)
    - [Ver las direcciones IP de mis contenedores](#ver-las-direcciones-ip-de-mis-contenedores)
    - [Ver las variables de entorno que tienen mis contenedores](#ver-las-variables-de-entorno-que-tienen-mis-contenedores)
    - [Acceder con un cliente de PostgreSQL a las bases de datos](#acceder-con-un-cliente-de-postgresql-a-las-bases-de-datos)
- [Eliminar objetos definitivamente](#eliminar-objetos-definitivamente)
    - [Purgar Organizaciones Borradas](#purgar-organizaciones-borradas)
    - [Purgar Grupos Borrados](#purgar-grupos-borrados)
    - [Purgar Datasets Borrados](#purgar-datasets-borrados)
    - [Listar nombres de los datasets contenidos en Andino](#listar-nombres-de-los-datasets-contenidos-en-andino)
- [Backups](#backups)
    - [Backup de la base de datos](#backup-de-la-base-de-datos)
    - [Realizar un backup del file system](#realizar-un-backup-del-file-system)
    - [Realizar un backup de la configuración](#realizar-un-backup-de-la-configuracion)
- [Comandos de DataPusher](#comandos-de-datapusher)
    - [Subir todos los recursos al Datastore](#subir-todos-los-recursos-al-datastore)
- [Seguridad](#seguridad)
    - [HTTPS](#https)
    - [Plugin ckanext-security](#plugin-ckanext-security)
    - [Sistema y librerías](#sistema-y-librerias)
    - [Firewall](#firewall)
    - [SSH](#ssh)
- [Optimización de logging](#optimizacion-de-logging)
    - [Configurar otro `logging driver`](#configurar-otro-logging-driver)
    - [Eliminar `logs` antiguos de `Docker`](#eliminar-logs-antiguos-de-docker)
    - [Eliminar logs dentro de Andino](#eliminar-logs-dentro-de-andino)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Exploración de la instancia de andino

### ¿Qué está corriendo docker?

Para obtener una lista de lo que está corriendo actualmente Docker, podemos usar el siguiente comando:

    docker ps # Tabla de ejecucion actual
    docker ps -q # Listado de IDs de cada contenedor
    docker ps -aq # Listado de IDs de todos los contenedores disponibles.
    
### Utilización del archivo latest.yml en los comandos de docker-compose

En múltiples secciones de esta documentación se emplea el uso de comandos que comienzan de la siguiente manera:

    docker-compose -f latest.yml

Es importante recordar que no alcanzaría con especificar el directorio absoluto del archivo `latest.yml`; es necesario 
ejecutar estos comandos _exactamente en ese mismo directorio_, debido a que ahí también se encuentra el archivo que 
contiene las variables de entorno (`.env`) ya que es el directorio de instalación de Andino.  


### Ingresar al contendor principal de andino

El contenedor principal de andino, donde se ejecuta la aplicación CKAN, es denominado `portal`. 
Para ingresar en una sesión de consola en el contenedor, ejecutar:

    docker-compose -f latest.yml exec portal /bin/bash
    
Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).


### Listar todas las `Propiedades` de cada contenedor

    docker-compose -f latest.yml ps -q portal solr db | xargs -n 1 | while read container; do docker inspect $container; done
    
Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).

## Administración de usuarios

### Crear un usuario ADMIN

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/add_admin.sh mi_nuevo_usuario_admin email_del_usuario_admin
    
Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).

El comando solicitará la contraseña del usuario administrador.


### Listar mis usuarios

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user list
    
Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).

### Ver los datos de un usuario

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user nombre-de-usuario
    
Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).


### Crear un nuevo usuario

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user add nombre-de-usuario
    
Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).


### Crear un nuevo usuario extendido

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user add nomber [email=mi-usuario@host.com password=mi-contraseña-rara apikey=unsecretomisticonoleible]
    
Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).

### Eliminar un usuario

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user remove nombre-de-usuario
    
Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).

### Cambiar password de un usuario

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/paster.sh --plugin=ckan user setpass nombre-de-usuario
    
Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).

### Usuario administrador de CKAN

Existe un usuario administrador llamado _default_, el cual es utilizado por la aplicación para la ejecución de ciertas 
funciones que corren de fondo (por ejemplo, la actualización de la caché del data.json). Es muy importante que dicho 
usuario **siempre** esté disponible ya que, en caso de no estarlo, provocaría un funcionamiento incorrecto en el 
portal; por lo tanto, se recomienda muy fuertemente no intentar eliminarlo ni desactivarlo.

## Configuraciones de andino

### Modificar el archivo de configuración

El archivo de configuración de andino se llama `production.ini`, y se lo puede encontrar y modificar 
de la siguiente manera:

```bash
# Ingresar al contenedor

cd /etc/portal
docker-compose -f latest.yml exec portal /bin/bash

# Una vez adentro, abrimos el archivo production.ini, y buscamos la sección que necesita ser modificada
 
vim /etc/ckan/default/production.ini

# Editamos y, luego de salir del contenedor, lo reiniciamos

docker-compose -f latest.yml restart portal nginx
```    

### Cambiar la configuración del SMTP

Por defecto, andino usará un servidor postfix integrado para el envío de emails.
Para usar un servidor SMTP propio, debemos cambiar la configuración del archivo `production.ini`.
Para lograrlo, podemos hacerlo de dos formas:

1 ) Ingresando al contenedor.

Debemos buscar y editar en el archivo `production.ini` la configuración
de email que luce como:

```
## Email settings

error_email_from=admin@example.com
smtp.server = postfix
#smtp.starttls = False
smtp.user = portal
smtp.password = portal
smtp.mail_from = administrador
```

Para saber cómo hacerlo, leer la sección que explica 
[cómo modificar el archivo de configuración](#modificar-el-archivo-de-configuracion)

2 ) Ejecutando comandos paster

Suponiendo que nuestro servidor SMTP está en smtp.gmail.com, la dirección de correo del usuario es `smtp_user_mail@gmail.com`, 
la contraseña de esa dirección de correo `mi_pass` y queremos usar "tls", podemos ejecutar los siguientes comandos:

```
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "smtp.server=smtp.gmail.com:587";
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "smtp.user=smtp_user_mail@gmail.com";
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "smtp.password=mi_pass";
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "smtp.starttls=True";
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "smtp.mail_from=smtp_user_mail@gmail.com";

# Finalmente reiniciamos el contenedor
docker-compose -f latest.yml restart portal nginx
```

Tener en cuenta que si se utiliza un servidor SMTP, se debe setear la configuración con **un correo electrónico 
de @gmail.com**, y que **starttls debe estar en True**.

### Cambiar el remitente de los correos electrónicos que envía Andino

Para modificar el remitente de los correos electrónicos que el sistema envía 
(por ejemplo los de creación de usuarios nuevos o los de olvido de contraseña), 
se deben seguir los pasos de la sección [Cambiar la configuración del SMTP](#cambiar-la-configuracion-del-smtp) 
pero modificando el atributo de configuración `smtp.mail_from`.

### Cambiar el id del container de Google Tag Manager

Será necesario modificar la configuración en el archivo `production.ini`.

Para saber cómo hacerlo, leer la sección que explica 
[cómo modificar el archivo de configuración](#modificar-el-archivo-de-configuracion).

Esta vez, buscaremos la configuración debajo de la sección [app:main] 
(vas a encontrar campos como "superThemeTaxonomy" y "ckan.site.title").

El campo que estamos buscando es `ckan.google_tag_manager.gtm_container_id`.


En caso de no encontrar el campo mencionado, lo podemos agregar:

`ckan.google_tag_manager.gtm_container_id = { id que necesitás guardar }`

### Google Tag Manager

Para configurar el código se seguimiento de Google Tag Manager ejecutar el siguiente comando:

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "ckan.google_tag_manager.gtm_container_id=<tu código de seguimiento GTM>";

    # Finalmente reiniciamos el contenedor
    docker-compose -f latest.yml restart portal nginx
    
### Cambiar el id del tag de Google Analytics

Será necesario modificar el archivo de configuración `production.ini`.

Para saber cómo hacerlo, leer la sección que explica 
[cómo modificar el archivo de configuración](#modificar-el-archivo-de-configuracion).

La sección a buscar luce de esta manera:

```
## Google Analytics
googleanalytics.id = { un id }
googleanalytics_resource_prefix = { un prefix }
googleanalytics.domain = { un dominio }
```

Lo que se debe modificar es el campo `googleanalytics.id`.

### Indexar datasets con Google Dataset Search

Andino cuenta con la posibilidad de utilizar Google Dataset Search para que éste indexe tus datasets.
Para el mejor entendimiento de la herramienta, recomendamos que entres a https://search.google.com/search-console/about.

Por default, esta configuración se encuentra desactivada. Para activarla, podés ir a 
_Configuración_ -> _Configuración avanzada_ -> _Google Dataset Search_ -> Clickear el checkbox y guardar el cambio.

### Deshabilitar la URL `/catalog.xlsx`

En caso de desear deshabilitar la URL `/catalog.xlsx`, se puede ejecutar el siguiente comando:

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "andino.disable_catalog_xlsx_url=True";

En caso de querer restaurarlo, se debe configurar el atributo `andino.disable_catalog_xlsx_url` con el valor `False`.
    
### Configuración de la llamada de invalidación de caché

La aplicación puede ser configurada para hacer una llamada HTTP ante cada cambio en los metadatos del portal.
Esta llamada (A.K.A. "hook") puede configurarse para ser a cualquier URL, y usando cualquier método HTTP.
Se deberá utilizar un campo llamado `andino.cache_clean_hook`, que tendrá asignada la URL a la cual
queremos enviarle requests HTTP que lograrán ese efecto.

Además, el paquete "Andino" provee una configuración de *nginx* que permite recibir esta llamada e invalidar la caché.

Para configurar internamente nginx y andino, sólo es necesario parar la opción `--nginx-extended-cache` al momento de
usar el script de instalación.

Si nuestra aplicación ya está instalada, podemos seguir los siguientes pasos:

1. Actualizar a la ultima versión de la aplicación, con el script de actualización.
1. Ir al directorio de instalación `cd /etc/portal`
1. Editar el archivo `.env`
1. Agregar una línea nueva que sea: `NGINX_CONFIG_FILE=nginx_extended.conf`
1. Reiniciar el contenedor de nginx `docker-compose -f latest.yml up -d nginx`

Luego configuramos el hook de invalidación:

1. Entramos al contenedor del portal: `docker-compose -f latest.yml exec portal bash`
1. Configuramos el hook: `/etc/ckan_init.d/update_conf.sh andino.cache_clean_hook=http://nginx/meta/cache/purge`
1. Salimos `exit`
1. Reiniciamos el portal: `docker-compose -f latest.yml restart portal nginx`

_Nota: tener en cuenta que, por defecto, se emplea el método PURGE para disparar el hook, lo cual
se puede cambiar editando el campo `andino.cache_clean_hook_method` dentro del archivo de configuración `production.ini`._
_Para saber cómo hacerlo, leer la sección que explica 
[cómo modificar el archivo de configuración](#modificar-el-archivo-de-configuracion)._ 

### Caché externa

Es posible implementar la caché externa por fuera del paquete andino.
Para esto, en el servidor que servirá de caché, necesitamos instalar [openresty](https://openresty.org/en/installation.html).
Esta plataforma web nos permite correr **nginx** y modificar su comportamiento usando [lua](https://www.lua.org/).

Luego de instalar **openresty**, debemos activarlo para que empiece cada vez que se prenda el servidor:

```
systemctl enable openresty
systemctl restart openresty
```

Luego de instalar `operesty`, debemos agregar los archivos de configuración.
Primero borramos la configuración de nginx que viene por defecto en `/etc/openresty/nginx.conf` y agregamos la nuestra:

```
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;

}
```


Luego, creamos el directorio donde pondremos la configuración de nuestra caché y creamos el archivo.

```
mkdir -p /etc/nginx/conf.d/
touch /etc/nginx/conf.d/000-andino-cache.conf
```

El archivo `000-andino-cache.conf` contendrá lo siguiente.
Es necesario cambiar la palabre `IP_A_ANDINO` por la IP donde está andino.

```
proxy_cache_path /tmp/nginx_cache/ levels=1:2 keys_zone=cache:30m max_size=250m;
proxy_temp_path /tmp/nginx_proxy 1 2;

server_tokens off;

server {
    client_max_body_size 300M;
    location / {
        proxy_pass http://IP_A_ANDINO:80/;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
        proxy_cache cache;

        # Disable cache for logged-in users
        proxy_cache_bypass $cookie_auth_tkt;
        proxy_no_cache $cookie_auth_tkt;
        proxy_cache_valid 30m;
        proxy_cache_key $host$scheme$proxy_host$request_uri;

        # Ignore apache "Cache-Control" header
        # See https://lists.okfn.org/pipermail/ckan-dev/2016-March/009864.html
        proxy_ignore_headers Cache-Control;
        # In emergency comment out line to force caching
        # proxy_ignore_headers X-Accel-Expires Expires;

        # Show cache status
        add_header X-Cache-Status $upstream_cache_status;
    }

    location /meta/cache/purge {
        allow  192.168.0.0/16;
        allow  172.16.0.0/12;
        allow  10.0.0.0/8;
        allow  127.0.0.1;
        deny   all;
        if ($request_method = PURGE ) {
            content_by_lua_block {
                filename = "/tmp/nginx_cache/"
                local f = io.open(filename, "r")
                if (f~=nil) then
                    io.close(f)
                    os.execute('rm -rf "'..filename..'"')
                end
                ngx.say("OK")
                ngx.exit(ngx.OK)
            }
        }
    }
}
```

Si se está utilizando la configuración SSL, agregar al final del archivo la siguiente sección, reemplazando _[el texto que aparezca entre corchetes (y éstos) por el valor adecuado]:

```
server {
  client_max_body_size 300M;
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name [Tu nombre de dominio];

  ssl_certificate [Path al certificado];
  ssl_certificate_key [Path a la llave del certificado];

  ssl_session_cache shared:SSL:50m;
  ssl_session_timeout 1d;
  ssl_session_tickets off;

  ssl_prefer_server_ciphers on;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';

  resolver 8.8.8.8 8.8.4.4;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_trusted_certificate [Path al certificado];

  add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";
  add_header X-Xss-Protection "1; mode=block" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-Frame-Options "SAMEORIGIN" always;
  proxy_ignore_headers Cache-Control;

  location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Protocol https;
    proxy_ignore_headers Cache-Control;
        add_header X-Xss-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
        proxy_redirect off;

        if (!-f $request_filename) {
            proxy_pass https://[Tu URL]:443;
            break;
        }
    }
}
```

Finalmente, reiniciamos **openresty**: `systemctl restart openresty`.

Ahora que tenemos la caché configurada, necesitamos configurar la llamada, o hook, de invalidación de caché.
Para esto, entramos al servidor donde está corriendo andino y corremos:

```bash
IP_INTERNA_CACHE=<ip interna del servidor de caché>

cd /etc/portal
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "andino.cache_clean_hook=http://$IP_INTERNA_CACHE/meta/cache/purge";
docker-compose -f latest.yml restart portal nginx
```

Si queremos probar la integración, podemos entrar al contenedor de andino y probar invalidar la caché:

```

IP_INTERNA_CACHE=<ip interna del servidor de caché>
cd /etc/portal
docker-compose -f latest.yml exec portal curl -X PURGE "http://$IP_INTERNA_CACHE/meta/cache/purge";
# =>  OK
```


**NOTA:** Si estamos usando nuestro andino con un IP y *no* con un dominio, tendremos que cambiar la
configuración `ckan.site_url` para que use la IP del servidor donde se encuentra la caché externa.

```bash

IP_PUBLICA_CACHE=<ip publica del servidor caché>

cd /etc/portal
docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "ckan.site_url=http://$IP_PUBLICA_CACHE";
docker-compose -f latest.yml restart portal nginx

```

### Especificar las licencias a utilizar

Existe un JSON que contiene las licencias a utilizar en el portal, y cuyo path es 
`/var/lib/ckan/theme_config/licenses.json`. Este archivo está especificado en el campo _licenses_group_url_ del 
archivo de configuración.

Es posible cambiarlo para lograr utilizar un archivo distinto; para ello, hay que cambiar el path por el deseado, 
teniendo en cuenta las siguientes indicaciones:
* Para utilizar un path de un archivo existente en el container, el mismo debe comenzar con el texto _file://_, tal y 
como ocurre con el path utilizado por default.
* Para utilizar una URL, debe comenzar con _http://_ o _https://_.

### Configuración de CORS

Cuando es necesario acceder a Andino desde URLs distintas que apuntan a una misma instancia 
(ej: accediendo a través de un gateway/caché o directamente a la instancia de Andino o usando la IP pública 
del servidor _host_) es necesario, para el correcto funcionamiento de Andino, configurar parámetros para habilitar 
CORS (_Cross-Origin Resource Sharing_). Esto se debe a que un Andino debe tener una URL canónica, por lo tanto, 
las demás URLs utilizadas deben estar en el _whitelist_ de CORS de Andino.

Para poder navegar tu Andino usando como URL una que no es la canónica de tu instancia, tenés que realizar dos acciones 
(los comandos deben ser ejecutados desde el directorio de instalación de Andino; por _default_, `/etc/portal`):

1. Habilitar el comportamiento CORS: `docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "ckan.cors.origin_allow_all = false"` (si bien el parámetro de configuración tiene el valor `false`, esto habilita el control de URLs contra el _whitelist_).
2. Agregar las URLs al _whitelist_: `docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "ckan.cors.origin_whitelist=http://localhost:8080 http://127.0.0.1 http://127.0.0.1:8080"` (en el ejemplo se habilitan las URLs `http://localhost:8080`, `http://127.0.0.1` y `http://127.0.0.1:8080`).

Luego reiniciá los contenedores `portal` y `nginx`: `docker-compose -f latest.yml restart nginx portal`.

Si deseás habilitar **todas** las URLs para CORS (no recomendado), en el paso 1 debés pasar el valor `true` para 
el atributo de configuración `ckan.cors.origin_allow_all`.

Para ver más acerca del funcionamiento de CORS en CKAN ver la 
[documentación oficial de CKAN (en inglés)](http://docs.ckan.org/en/ckan-2.7.3/maintaining/configuration.html#cors-settings).

### Configuración del explorador de series de tiempo

Andino tiene instalado el plugin [ckanext-seriestiempoarexplorer](https://github.com/datosgobar/ckanext-seriestiempoarexplorer), 
pero no se encuentra presente entre los plugins activos.
Para activarlo, debemos entrar al contenedor de andino, editar el archivo `/etc/ckan/default/production.ini` y agregar
el `seriestiempoarexplorer` a la lista de plugins.
Luego de agregarlo, debemos reinicar el servidor.


```
cd /etc/portal
docker-compose -f latest.yml exec portal bash;
vim /etc/ckan/default/production.ini
# ...
apachectl restart
```

Luego, si vamos a la configuración del sitio, podremos apreciar que se agrego una nueva sección "Series" en el apartado
 "Otras secciones del portal".

### Reemplazar Datapusher por el plugin ckanext-xloader

Este plugin fue desarrollado para cumplir con el mismo fin que Datapusher (subir ciertos archivos al Datastore) de una 
manera más eficiente, mantenible y robusta. Para más información, se puede leer 
[la documentación del plugin](https://github.com/ckan/ckanext-xloader).

Si se desea realizar el reemplazo, se debe ejecutar el script que lo lleva a cabo y se encuentra en el path 
`/etc/ckan_init.d/datastore_loaders/enable_ckanext_xloader.sh`. Su ejecución incluye la deshabilitación del Datapusher.

Es muy importante aclarar que **no se puede tener activados ambos servicios al mismo tiempo**, sino que se debe elegir 
entre uno u otro. Por esa razón, si se implementó alguna funcionalidad extra a Andino que requiere la presencia de 
Datapusher, no será posible utilizar el xloader.

Xloader provee un comando de paster para subir recursos al Datastore desde consola:
`/usr/lib/ckan/default/bin/paster --plugin=ckanext-xloader xloader submit X -c /etc/ckan/default/production.ini`, donde 
se debe reemplazar la X para especificar un id o nombre de dataset en particular o "all" para subir los recursos de 
todos los datasets del portal.

Las tareas croneadas para la subida automática de recursos al Datastore que existan en el contenedor serán modificadas 
para utilizar el comando específico del plugin que haya sido activado.

En caso de querer reestablecer Datapusher como el servicio a utilizar, se debe ejecutar el script 
`/etc/ckan_init.d/datastore_loaders/enable_datapusher.sh`.

## Acceso a los datos de andino

### Encontrar los volúmenes de mi andino dentro del filesystem del host

    docker-compose -f latest.yml ps -q andino solr db | xargs -n 1 | while read container; do docker inspect -f ' {{.Name}}: {{range .Mounts}}{{.Source}}: {{.Destination}}  {{end}} ' $container; done

Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).

### Ver las direcciones IP de mis contenedores

    docker-compose -f latest.yml ps -q andino solr db | xargs -n 1 | while read container; do docker inspect -f '{{.Name}}: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container; done

### Ver las variables de entorno que tienen mis contenedores

    docker-compose -f latest.yml ps -q andino solr db | xargs -n 1 | while read container; do docker inspect -f '{{range $index, $value := .Config.Env}}export {{$value}}{{println}}{{end}}' $container; done

Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).

### Acceder con un cliente de PostgreSQL a las bases de datos

    docker-compose -f dev.yml exec db psql -U postgres
    # psql \c ckan db default CKAN
    # psql \c datastore_default db datastore CKAN

## Eliminar objetos definitivamente

Es bien sabido que, dentro de CKAN, cada vez que borranmos algun elemento, en verdad no se borra, sino que pasa a estar 
inactivo; por lo tanto, tener alguna forma de eliminar elementos de manera definitiva resulta altamente necesario.

### Purgar Organizaciones Borradas

    curl -X POST http://tu-host/api/3/action/organization_purge -H "Authorization:tu-api-key" -F id=id-o-nombre-que-se-desea-borrar

### Purgar Grupos Borrados

    curl -X POST http://tu-host/api/3/action/group_purge -H "Authorization:tu-api-key" -F id=id-o-nombre-que-se-desea-borrar

### Purgar Datasets Borrados

    curl -X POST http://tu-host/api/3/action/dataset_purge -H "Authorization:tu-api-key" -F id=id-o-nombre-que-se-desea-borrar


### Listar nombres de los datasets contenidos en Andino

```bash
docker-compose -f latest.yml exec portal /etc/ckan_init.d/paster.sh  --plugin=ckan dataset list | grep -v DEBUG | grep -v count  | grep -v Datasets | xargs -n2 | while read id name; do echo $name; done
```
Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).


## Backups

Es altamente recomendable hacer copias de seguridad de los datos de la aplicación, tanto la base de datos como los 
archivos de configuración y subidos por los usuarios.

### Backup de la base de datos

Un ejemplo fácil de hacer un backup de la base de datos sería:

    container=$(docker-compose -f latest.yml ps -q db)
    today=`date +%Y-%m-%d.%H:%M:%S`
    filename="backup-$today.gz"

    # Creo un directorio temporal y defino dónde generaré el backup
    backupdir=$(mktemp -d)
    backupfile="$backupdir/$filename"

    # Exporto la base de datos
    docker exec $container pg_dumpall -c -U postgres | gzip > "$backupfile"

    # Copio el archivo al directorio actual y borro el original
    # Podría reemplazar $PWD con mi directorio de backups, como /etc/portal/backups
    mv "$backupfile" $PWD


Y para los demás archivos de la aplicación (requiere [`jq`](https://stedolan.github.io/jq/)):

    backupdir=$(mktemp -d)
    today=`date +%Y-%m-%d.%H:%M:%S`
    appbackupdir="$backupdir/application/"
    mkdir $appbackupdir
    container=$(docker-compose -f latest.yml ps -q portal)

    docker inspect --format '{{json .Mounts}}' $container  | jq -r '.[]|[.Name, .Source, .Destination] | @tsv' |
    while IFS=$'\t' read -r name source destination; do

        if ls $source/* 1> /dev/null 2>&1; then
            dest="$appbackupdir$name"
            mkdir -p $dest

            tar -C "$source" -zcvf "$dest/backup_$today.tar.gz" $(ls $source)
        else
            echo "No file at $source"
        fi
    done

    tar -C "$appbackupdir../" -zcvf backup.tar.gz "application/"

Podria colocarse esos scripts en el directorio donde se instaló la aplicación 
(ejemplo : `/etc/portal/backup.sh`) y luego agregar un `cron`:

Para correr el script cada domingo, podríamos usar la configuración `0 0 * * 0` 
(ver [cron](https://help.ubuntu.com/community/CronHowto) para más información), 
correr el comando `crontab -e` y agregar la línea:

    0 0 * * 0 cd /etc/portal/ && bash /etc/portal/backup.sh


### Realizar un backup del file system

    # Exporto el path al almacenamiento del volumen
    export CKAN_FS_STORAGE=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/lib/ckan" }}{{ .Source }}{{ end }}{{ end }}' andino)

    # Creo un tar.gz con la info.
    tar -C "$(dirname "$CKAN_FS_STORAGE")" -zcvf /ruta/para/guardar/mis/bkps/mi_andino.fs-data_$(date +%F).tar.gz "$(basename "$CKAN_FS_STORAGE")"


### Realizar un backup de la configuración


    # Exporto el path al almacenamiento del volumen
    export ANDINO_CONFIG=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/etc/ckan/default" }}{{ .Source }}{{ end }}{{ end }}' andino)

    # Creo un tar.gz con la info.
    tar -C "$(dirname "$ANDINO_CONFIG")" -zcvf /ruta/para/guardar/mis/bkps/mi_andino.config-data_$(date +%F).tar.gz "$(basename "$ANDINO_CONFIG")"


## Comandos de DataPusher

Deben ser corridos en el directorio de instalación de Andino.

### Subir todos los recursos al Datastore

Es posible que existan recursos que no hayan sido subidos al Datastore. Para buscar e intentar subir dichos recursos, ejecutar:

    docker-compose -f latest.yml exec portal /usr/lib/ckan/default/bin/paster --plugin=ckan datapusher submit_all -c /etc/ckan/default/production.ini
    
Se preguntará si se desea proceder. Al escribir que sí (`y`), iniciar la subida de recursos. Para cada uno de ellos, se escribirá su id y luego el status: si subió correctamente, aparecerá "_OK_"; en caso contrario, "_FAIL_".


## Seguridad

Mantener seguro un servidor web puede ser una tarea ardua, pero sobre todo es _constante_, ya que _constantemente_ 
se detectan nuevas vulnerabilidades en los distintos softwares.
Y un servidor web no es la excepción!
En este breve apartado, se darán pequeñas recomendaciones para mantener seguro el servidor, 
no solo antes posibles atacantes, sino tambien ante posibles fallos del sistema y como efectuar mitigaciones.

Las siguientes recomendaciones puden ser implementadas fácilmente en un sistema Ubuntu 16.04, el cual es el 
recomendado (a la fecha), para correr la aplicación.

### HTTPS

HTTPS permite que la conexión entre el _browser_ y el servidor sea encriptada y de esta manera segura.
Es altamente recomendable usar HTTPS, para mantener la privacidad de los usuarios.
El portal de documentación para desarrolladores de Google provee buena información sobre esto:
https://developers.google.com/web/fundamentals/security/encrypt-in-transit/why-https

### Plugin ckanext-security

Para las versiones 2.5.7 en adelante, existe un plugin para mejorar la seguridad de CKAN que se puede encontrar 
[en github](https://github.com/data-govt-nz/ckanext-security). Para su utilización, es necesario el uso de 
certificados SSL, ya sea en Andino mismo (teniendo _https_ en el campo `site_url` de la configuración del portal) o 
mediante un reverse proxy.

Para este plugin existen dos scripts, los cuales se pueden encontrar en el directorio `/etc/ckan_init.d/security` 
dentro del contenedor de Andino; uno para activarlo (`enable_ckanext_security.sh`) y otro para desactivarlo 
(`disable_ckanext_security.sh`). Sólo se necesita ejecutar el que se necesite y reiniciar apache.

### Sistema y librerías

Es _altamente recomendable_ mantener el sistema operativo y las aplicaciones que usemos actualizadas. 
Constantemente se están subiendo _fixes_ de seguridad y posibles intrusos podrían aprovechar que las aplicaciones 
o el mismo sistema operativo estén desactualizados.
Periódicamente, podríamos constatar las nuevas versiones de nuestro software y actualizar dentro de lo posible. 
Como ejemplo, podemos ver que para Ubuntu 16.04 salió Ubuntu 16.04.2, con algunas correcciones de seguridad. 
[Ver](https://wiki.ubuntu.com/XenialXerus/ReleaseNotes/ChangeSummary/16.04.2).

### Firewall

**Todo servidor debe tener activado el firewall.** El firewall permitirá denegar (o permitr) el acceso a la red. 
En un servidor web, el puerto abierto al público deberían ser sólo el 80 (http) y el 443 (https). Además de ese puerto, 
si la máquina es accedida remotamente mediante un servidor SSH, deberíamos abrir este puerto también, 
pero con un límite de acceso.
La solución es fácilmente implementable con el programa [`ufw`](https://help.ubuntu.com/community/UFW).

### SSH

Los servidores ssh permiten el acceso al servidor remotamente. 
**No debe permitirse el acceso por ssh mediante usuario y password**. 
Sólo debe permitirse el acceso mediante clave publica.
DigitalOcean tiene una buena guía de cómo configurar las claves públicas 
[Ver](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2).


## Optimización de logging

### Configurar otro `logging driver`

Por default, docker escribe a un archivo con formato `json`, lo cual puede llevar a que se acumulen los logs de la 
aplicación, y estos archivos crezcan indefinidamente.
Para evitar esto, se puede configurar el [`logging driver`](https://docs.docker.com/engine/admin/logging/overview/) 
de docker.
La recomendacion es usar `journald` y configurarlo para que los logs sean persistentes. 

### Eliminar `logs` antiguos de `Docker`

Dentro del normal funcionamiento de la plataforma, se genera una gran cantidad de logs, los cuales, ante un incidencia, 
son sumamente útiles. Pero, luego de un tiempo, y sabiendo que los mismos se almacenan internamente en Andino, podría 
ser necesario eliminarlos.

    sudo su -c "ls  /var/lib/docker/containers/ | xargs -n1 | while read docker_id; do truncate -s 0 /var/lib/docker/containers/${docker_id%/*}/${docker_id%/*}-json.log; done"

### Eliminar logs dentro de Andino

    docker-compose -f latest.yml exec portal truncate -s 0 /var/log/apache2/*.log

Ver [la sección sobre la utilización del archivo latest.yml en los comandos de docker-compose](#utilizacion-del-archivo-latest.yml-en-los-comandos-de-docker-compose).
