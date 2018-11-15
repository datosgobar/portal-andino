<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Configuración HTTPS](#configuraci%C3%B3n-https)
  - [Certificado SSL](#certificado-ssl)
  - [Configuracion de SSL](#configuraci%C3%B3n-de-ssl)
          - [Modificar el puerto](#modificar-el-puerto)
          - [Realizar cambios en un Andino instalado](#realizar-cambios-en-un-andino-instalado)
  - [Probar la configuración](#probar-la-configuraci%C3%B3n)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Configuración HTTPS

## Certificado SSL

Debemos contar con los certificados `.key` y `.crt` para nuestra aplicación.
Cómo obtenerlos está fuera del "scope" de esta documentación.

## Configuración de SSL

Tanto la instalación como la actualización de un Andino emplean el uso de un parámetro llamado `nginx_ssl`, el cual 
puede ser utilizado para especificar que se desea utilizar SSL.

Para especificar el path de los archivos del certificado, se debe utilizar los parámetros `ssl_key_path` y 
`ssl_crt_path`. Los archivos dentro de la instancia de Nginx se llamarán _`andino.key`_ y _`andino.crt`_ 
respectivamente, y se encontrarán en el directorio _`/etc/nginx/ssl`_. En caso de que al menos uno de estos archivos no 
esté, _no se podrá utilizar el archivo de configuración para SSL_ y se elegirá el default en su lugar. Hay que 
asegurarse de que el path de cada archivo sea válido (exista en el host), y que estén especificados en la 
instalación/actualización.

El explorador *no debería* mostrarnos ninguna advertencia si los certificados son correctos.

Un ejemplo de uso dentro del comando de instalación de Andino para los parámetros mencionados:
```
--nginx_ssl --ssl_key_path="/home/miusuario/Desktop/mi_archivo_key.key" --ssl_crt_path="/home/miusuario/Desktop/mi_archivo_crt.crt"
```

El archivo de configuración para Nginx a utilizar queda guardado como variable de entorno en el archivo _`.env`_ dentro 
del directorio donde fue instalado el portal (por default, _`/etc/portal`_). Esto significa que, si ya se implementó 
el SSL, no será necesario volver a especificarlo mediante parámetros al actualizar Andino.

Cuando el contenedor de Nginx se levante, puede tardar hasta dos minutos para que se pueda acceder al portal.

### Modificar el puerto

Para la instalación de Andino, el puerto a ser utilizado por default es el 443, pero éste puede ser cambiado mediante 
el parámetro `nginx_ssl_port` y un valor a elección.

Ejemplo:
```
--nginx_ssl_port="4567"
```

### Realizar cambios en un Andino instalado

Para lograr que Andino implemente la configuración HTTPS, no es necesario realizar una actualización; basta con abrir 
el archivo _`.env`_ y agregar/modificar la siguiente línea para que quede de esta forma:
```
NGINX_CONFIG_FILE=nginx_ssl.conf
```

El siguiente paso consiste en traer los archivos del certificado al contenedor de Nginx. Puede realizarse de la 
siguiente forma, utilizando los paths correctos a dichos archivos dentro del host:

`docker cp /path/a/archivo_key.key andino-nginx:/etc/nginx/ssl/andino.key`
`docker cp /path/a/archivo_crt.crt andino-nginx:/etc/nginx/ssl/andino.crt`

Si se desea dejar de utilizar la configuración HTTPS, se debe modificar la misma línea para que quede de esta forma:
```
NGINX_CONFIG_FILE=nginx.conf
```

Luego de realizar la modificación deseada, se deberá reiniciar el contenedor de Nginx:
`docker-compose -f latest.yml restart nginx` 


## Probar la configuración

Para asegurarse de que Nginx esté utilizando la configuración HTTPS, ejecutar el siguiente comando debería mostrar 
`nginx_ssl.conf`:

`docker exec -it andino-nginx bash -c 'echo $NGINX_CONFIG_FILE'`. 

Si se está implementando la configuración HTTPS y los certificados fueron creados correctamente, el explorador debería 
redirigir cualquier llamada HTTP a HTTPS.

Si se especificó un puerto para SSL, el portal debería permitir el ingreso si el puerto es parte de la URL.
