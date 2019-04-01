# Configuración HTTPS

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Indice

- [Certificado SSL](#certificado-ssl)
- [Configuración de SSL](#configuracion-de-ssl)
    - [Modificar el puerto](#modificar-el-puerto)
    - [Realizar cambios en un Andino instalado](#realizar-cambios-en-un-andino-instalado)
- [Probar la configuración](#probar-la-configuracion)
- [Renovar certificados SSL](#renovar-certificados-ssl)
- [Deshabilitar SSL](#deshabilitar-ssl)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Certificado SSL

Andino cuenta con soporte _builtin_ de certificados SSL. Es posible instalar Andino con SSL, actualizar una versión de Andino sin SSL y agregarle el soporte para SSL, e inclusive deshabilitar SSL a una instancia con SSL.

Lo único que un administrador de Andino necesita para habilitar SSL es contar con los certificados `.key` y `.crt` para nuestra aplicación y la elección de un puerto libre del host para usar SSL.

Cómo obtener estos archivos está fuera del "scope" de esta documentación.

## Configuración de SSL

Tanto la instalación como la actualización de un Andino emplean el uso de un parámetro llamado `nginx_ssl`, el cual 
puede ser utilizado para especificar que se desea utilizar SSL.

Para especificar el path de los archivos del certificado, se debe utilizar los parámetros `ssl_key_path` y 
`ssl_crt_path`. Los archivos dentro del contenedor `nginx` se llamarán _`andino.key`_ y _`andino.crt`_ 
respectivamente, y el proceso de instalación o actualización los copiará en el directorio _`/etc/nginx/ssl`_. En caso de que al menos uno de estos archivos no 
esté, _no se podrá utilizar el archivo de configuración para SSL_ y se elegirá el default en su lugar. Hay que 
asegurarse de que el path de cada archivo sea válido (exista en el host), y que estén especificados en la 
instalación/actualización.

Un navegador web *no debería* mostrarnos ninguna advertencia si los certificados son correctos.

Un ejemplo de uso dentro del comando de instalación de Andino para los parámetros mencionados:
```
--nginx_ssl --ssl_key_path="/home/miusuario/Desktop/mi_archivo_key.key" --ssl_crt_path="/home/miusuario/Desktop/mi_archivo_crt.crt"
```

Estos parámetros de configuración deben ser especificados en cada actualización de Andino, para mantener SSL habilitado.

### Modificar el puerto

Para la instalación de Andino, el puerto a ser utilizado por default es el 443, pero éste puede ser cambiado mediante 
el parámetro `nginx_ssl_port` y un valor a elección.

Ejemplo:
```
--nginx_ssl_port=8443
```

  Es importante para los administradores saber que Andino tomará el puerto especificado (o el default) ya sea que el portal use o no use HTTPS. En caso de no querer usar HTTPS y que el host tenga erl puerto 443 tomado por un servidor web, es requisito especificar un puerto distinto (ejemplo: 8443) que será reservado por Andino, pero no utilizado.

### Realizar cambios en un Andino instalado

Para lograr que Andino implemente la configuración HTTPS, es necesario realizar una actualización de andino y especificar las opciones detalladas en la sección [Configuración de SSL](#configuracion-de-ssl).

Estas opciones solo son válidas a partir de Andino `release-2.5.2`.

## Probar la configuración

Para asegurarse de que Nginx esté utilizando la configuración HTTPS, ejecutar el siguiente comando debería mostrar 
`nginx_ssl.conf`:

`docker exec -it andino-nginx bash -c 'echo $NGINX_CONFIG_FILE'`. 

Si se está implementando la configuración HTTPS y los certificados fueron creados correctamente, el explorador debería 
redirigir cualquier llamada HTTP a HTTPS.

Si se especificó un puerto para SSL, el portal debería permitir el ingreso si el puerto es parte de la URL.

También deberías poder navegar el portal en el puerto SSL seleccionado.

## Renovar certificados SSL

Para renovar los certificados SSL de tu instancia de Andino es tan sencillo como ejecutar una actualización de Andino. Para llevarlo a cabo es necesario que subas los dos archivos que componen el certificado (`.cer` y `.key`) y que ejecutes el comando de actualización de Andino, especificando la opción `--nginx_ssl` y las opciones que permiten configurar los archivos del certificado como estaá especificado en la sección [Configuración de SSL](#configuracion-de-ssl).

Si deseás mantener la versión de Andino que tenés, debés especificar la opción `--andino_version` con la versión de tu instancia de Andino.

## Deshabilitar SSL

El proceso de deshabilitación de SSL se puede lograr mediante la ejecución del proceso de actualización de Andino `update.py` especificando el parámetro `--andino_version` a una versión igual a la del portal a configurar (es decir, se mantendrá la misma versión), pero no especificando el parámetro `--nginx_ssl`.

De esta manera el script de actualización usará la configuración de Andino que no habilita HTTPS y se habilitará el acceso por el puerto 80.

Ejemplo de uso:

    sudo wget https://raw.github.com/datosgobar/portal-andino/master/install/update.py
    sudo python update.py --andino_version=<versión del andino del portal>
