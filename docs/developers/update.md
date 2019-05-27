# Actualización

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Indice

- [Versiones 2.x](#versiones-2x)
    - [Actualización simple](#actualizacion-simple)
    - [Actualización avanzada](#actualizacion-avanzada)
    - [Andino con plugins ad-hoc](#andino-con-plugins-ad-hoc)
    - [Versiones 2.5.6 en adelante](#versiones-256-en-adelante)
    - [Versiones 2.5.5 en adelante](#versiones-255-en-adelante)
    - [Versiones 2.5.0 y 2.5.1](#versiones-250-y-251)
    - [Versiones entre 2.4.0 y 2.5.3](#versiones-entre-240-y-253)
    - [Versiones 2.4.x a 2.5.x](#versiones-24x-a-25x)
- [Versiones 1.x a 2.x](#versiones-1x-a-2x)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Versiones 2.x

**Nota: si actualizás desde una versión 2.4.x a una versión 2.5.x ver [Versiones 2.4.x a 2.5.x](#versiones-24x-a-25x) ANTES de proceder con la actualización**

### Actualización simple

Si instalamos la aplicación con la última versión del instalador 
([este](https://raw.github.com/datosgobar/portal-andino/master/install/install.py)), 
el mismo no requerirá parámetros, pero contiene algunos opcionales:

```bash
# Parámetros de update.py
    [-h]                    Mostrar la ayuda del script
    [--install_directory INSTALL_DIRECTORY]
        Directorio donde está instalada la aplicación.
        Por defecto es `/etc/portal`
    [--site_host SITE_HOST]
        Dominio o IP del la aplicación *sin el protocolo*. Ver [una forma alternativa de actualizarlo](/docs/developers/checklist.md#verificar-si-mi-andino-tiene-el-nombre-de-dominio-configurado-correctamente)
    [--nginx-extended-cache]
        Configura nginx con una configuración extendida y configura el hook de
        invalidación de cache de Andino para notificar a nginx
    [--nginx_ssl]
        Aplica la configuración HTTPS en nginx. Requiere ambos archivos del certificado SSL para poder lograrlo; en 
        caso contrario, se utilizará la configuración default
    [--ssl_key_path SSL_KEY_PATH]
        Path dentro del host donde está ubicado el archivo .key para el certificado SSL; será copiado al contenedor 
        de nginx si tanto éste como el .crt pueden ser encontrados
    [--ssl_crt_path SSL_CRT_PATH]
        Path dentro del host donde está ubicado el archivo .crt para el certificado SSL; será copiado al contenedor 
        de nginx si tanto éste como el .key pueden ser encontrados
    [--nginx_port NGINX_PORT]
        Puerto del servidor "Host" que se desea que se tome para recibir llamadas HTTP.
        Por defecto es el 80.
    [--nginx_ssl_port NGINX_SSL_PORT]
        Puerto del servidor "Host" que se desea que se tome para recibir llamadas HTTPS.
        Por defecto es el 443.
        Es importante para los administradores saber que Andino tomará el puerto especificado (o el default) ya sea que el portal use o no use HTTPS. En caso de no querer usar HTTPS y que el host tenga erl puerto 443 tomado por un servidor web, es requisito especificar un puerto distinto (ejemplo: 8443) que será reservado por Andino, pero no utilizado.
    [--file_size_limit FILE_SIZE_LIMIT]
        Configura el límite de tamaño para subida de archivos en recursos. 
```

Para esta actualización de ejemplo, usaremos los valores por defecto:

    sudo wget https://raw.github.com/datosgobar/portal-andino/master/install/{update,installation_manager}.py
    sudo python update.py

De esta forma, el script asumirá que instalamos la aplicación en `/etc/portal`.

### Actualización avanzada

Si instalamos la aplicación en otro directorio distinto de `/etc/portal`, necesitamos correr el script de una manera diferente.
Suponiendo que instalamos la aplicación en `/home/user/app/`, debemos correr los siguientes pasos:

    wget https://raw.github.com/datosgobar/portal-andino/master/install/{update,installation_manager}.py
    sudo python update.py --install_directory="/home/user/app/"

### Andino con plugins ad-hoc

Si configuraste tu instancia de Andino con algún plugin de CKAN que Andino no trae por defecto, es importante que antes de la instalación elimines los mismos de la opcioón de configuración `ckan.plugins` del archivo `/etc/ckan/default/production.ini` del contenedor `portal`. Esto es importante, ya que el proceso de actualización descarga imágenes de Docker nuevas que no contendrán los binarios de los plugins _ad-hoc_ y si los mismos están en el archivo de configuración de CKAN, la actualización fallará.

Los pasos adicionales que deberás seguir si tenés plugins _ad-hoc_ son:

1. Editar el archivo `/etc/ckan/default/production.ini` del contenedor `portal` y quitar de la lista de `ckan.plugins` los plugins _ad-hoc_.
1. Actualizar Andino.
1. Instalar los plugins _ad-hoc_ dentro del _virtualenv_ `/usr/lib/ckan/default` del contenedor `portal`.
1. Editar el archivo `/etc/ckan/default/production.ini` del contenedor `portal` y agregar a la lista de `ckan.plugins` los plugins _ad-hoc_.
1. Reiniciar Andino.

### Versiones 2.5.7 en adelante

* Se especificó en el archivo de configuración (`production.ini`) un nuevo path donde ahora se encuentra un JSON que 
contiene las unidades que utiliza Andino; `/var/lib/ckan/theme_config/units.json`. Se deberá tener en cuenta al 
actualizar si el campo _units_url_ dentro del archivo de configuración había sido modificado manualmente, ya 
que se correrá una migración para utilizar el path correspondiente al JSON nombrado.

### Versiones 2.5.6 en adelante

* Se especificó en el archivo de configuración (`production.ini`) un nuevo path donde ahora se encuentra un JSON que 
contiene las licencias que utiliza Andino; `/var/lib/ckan/theme_config/licenses.json`. Se deberá tener en cuenta al 
actualizar si el campo _licenses_group_url_ dentro del archivo de configuración había sido modificado manualmente, ya 
que se correrá una migración para utilizar el path correspondiente al JSON nombrado.

### Versiones 2.5.5 en adelante

* Es necesario asegurarse de que la versión de Docker instalada sea una igual o más reciente a 17.05.0-ce (2017-05-04).

* Debido a la posibilidad de que ocasionen problemas durante la instalación, se removieron los plugin `harvest` y 
`datajson` del archivo de configuración, y se agregó una migración para eliminarlos al actualizar Andino para evitar 
posibles problemas. 

  * De ser necesaria la utilización de los plugins mencionados, deberán ser añadidos manualmente una vez finalizada la 
actualización.  

### Versiones 2.5.0 y 2.5.1

Si actualizás de 2.5.0 o 2.5.1 a 2.5.2 o una versión más nueva, hay que modificar el archivo de configuración para que 
`googleanalytics` esté _sólo una vez y al final_ en `ckan.plugins`.

Para ver cómo modificar el archivo de configuración, ir a [la documentación de mantenimiento](/docs/developers/maintenance.md#modificar-el-archivo-de-configuracion).

Ejemplo de cómo podría quedar:
`ckan.plugins = datajson_harvest datajson harvest ckan_harvester stats text_view image_view recline_view hierarchy_display hierarchy_form dcat structured_data gobar_theme datastore datapusher seriestiempoarexplorer googleanalytics`

### Versiones entre 2.4.0 y 2.5.3

Al actualizar un portal cuya versión se encuentra entre 2.4.0 y 2.5.3 a una versión más nueva, existe un comando que 
se debe ejecutar debido a problemas con el guardado de archivos de recursos (no se puede descargar un archivo de 
recurso si éste fue editado sin que se actualizara el archivo).

Este comando recuperará los archivos de recursos para los cuales se cumplan estas condiciones:
- El recurso es local
- El recurso posee el campo `downloadURL` en el data.json
- El archivo del recurso existe en el Datastore (su extensión debe ser _csv_, _xls_ o _xlsx_) y no está vacío

Existen 3 métodos para ejecutar la actualización de los recursos:

1. Actualizar sólo aquellos recursos cuyos archivos **no** sean descargables y cumplan con las condiciones detalladas 
más arriba
2. Actualizar todos los recursos que simplemente cumplan con las condiciones detalladas más arriba
3. Especificar uno o más IDs de los recursos que se quieran actualizar (en vez de modificar todos los posibles)

_Nota: Los métodos 2) y 3) son combinables._

Para poder implementar la solución una vez hecha la actualización del portal, se debe ejecutar los siguientes comandos:

```bash
docker-compose -f latest.yml exec portal bash
cd /usr/lib/ckan/default/src/ckanext-gobar-theme
/usr/lib/ckan/default/bin/paster --plugin=ckan reupload-resources-files --config=/etc/ckan/default/production.ini
exit
```
Para cada método mencionado, la tercera línea a ejecutar (el comando de actualización de recursos) será distinta:

1. Dejar el comando tal y como está, ya que es el comportamiento default
2. Escribir después del texto `reupload-resources-files` el flag `--force=true`
3. Escribir después del texto `reupload-resources-files` (o del flag `--force=true` si se lo utilizó) todos los IDs de 
los recursos a actualizar

Ejemplo de cómo quedaría si se quiere utilizar los métodos 2) y 3) actualizando dos recursos distintos:

`/usr/lib/ckan/default/bin/paster --plugin=ckan reupload-resources-files --force=true 
a57e4006-9e15-4bc7-b46a-25bf3580e538 t5t4rp09-156s-xzq2-36vl-2d5e8fghn98q --config=/etc/ckan/default/production.ini`


### Versiones 2.4.x a 2.5.x

En el caso de actualizar un Andino de versión 2.4.x a 2.5.x existe un error conocido de CKAN 2.5.8 (Ver issue [ckan/ckan#4168](https://github.com/ckan/ckan/issues/4168)) que **debe solucionarse ANTES de ejecutar la actualización**. 

En el procedimiento normal, ocurriría un error: `sqlalchemy.exc.ProgrammingError: (ProgrammingError) column package.metadata_created does not exist`

Para poder solucionarlo, se debe correr el siguiente script **antes de ejecutar el procedimiento normal de actualización**:

```bash
docker-compose -f latest.yml exec -u postgres db psql -c "
do \$$
begin
 IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name='package' AND column_name='metadata_created') OR
     NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name='package_revision' AND column_name='metadata_created') THEN

        IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name='package_revision' AND column_name='metadata_created') THEN
            ALTER TABLE package_revision ADD COLUMN metadata_created timestamp without time zone;
        END IF;

        IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name='package' AND column_name='metadata_created') THEN
            ALTER TABLE package ADD COLUMN metadata_created timestamp without time zone;
        END IF;

        UPDATE package SET metadata_created=
            (SELECT revision_timestamp
             FROM package_revision
             WHERE id=package.id
             ORDER BY revision_timestamp ASC
             LIMIT 1);
    END IF;
end \$$
" ckan
```

## Versiones 1.x a 2.x

Ver documento de [migración](migration.md)
