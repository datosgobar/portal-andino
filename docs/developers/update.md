<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Indice

- [Actualización](#actualizacion)
  - [Versiones 2.x](#versiones-2x)
    - [Actualización simple](#actualizacion-simple)
    - [Actualización avanzada](#actualizacion-avanzada)
    - [Andino con plugins ad-hoc](#andino-con-plugins-ad-hoc)
    - [Versiones 2.5.0 y 2.5.1](#versiones-2.5.0-y-2.5.1)
    - [Versiones entre 2.4.0 y 2.5.3](#versiones-entre-2.4.0-y-2.5.3)
    - [Versiones 2.4.x a 2.5.x](#versiones-24x-a-25x)
  - [Versiones 1.x a 2.x](#versiones-1x-a-2x)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Actualización

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
```

Para esta actualización de ejemplo, usaremos los valores por defecto:

    sudo wget https://raw.github.com/datosgobar/portal-andino/master/install/update.py
    sudo python update.py

De esta forma, el script asumirá que instalamos la aplicación en `/etc/portal`.

### Actualización avanzada

Si instalamos la aplicación en otro directorio distinto de `/etc/portal`, necesitamos correr el script de una manera diferente.
Suponiendo que instalamos la aplicación en `/home/user/app/`, debemos correr los siguientes pasos:

    wget https://raw.github.com/datosgobar/portal-andino/master/install/update.py
    sudo python update.py --install_directory="/home/user/app/"

### Andino con plugins ad-hoc

Si configuraste tu instancia de Andino con algún plugin de CKAN que Andino no trae por defecto, es importante que antes de la instalación elimines los mismos de la opcioón de configuración `ckan.plugins` del archivo `/etc/ckan/default/production.ini` del contenedor `portal`. Esto es importante, ya que el proceso de actualización descarga imágenes de Docker nuevas que no contendrán los binarios de los plugins _ad-hoc_ y si los mismos están en el archivo de configuración de CKAN, la actualización fallará.

Los pasos adicionales que deberás seguir si tenés plugins _ad-hoc_ son:

1. Editar el archivo `/etc/ckan/default/production.ini` del contenedor `portal` y quitar de la lista de `ckan.plugins` los plugins _ad-hoc_.
1. Actualizar Andino.
1. Instalar los plugins _ad-hoc_ dentro del _virtualenv_ `/usr/lib/ckan/default` del contenedor `portal`.
1. Editar el archivo `/etc/ckan/default/production.ini` del contenedor `portal` y agregar a la lista de `ckan.plugins` los plugins _ad-hoc_.
1. Reiniciar Andino.

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
* El recurso es local
* El recurso posee el campo `downloadURL` en el data.json
* El archivo del recurso existe en el Datastore (su extensión debe ser _csv_, _xls_ o _xlsx_) y no está vacío

Para poder implementar la solución, una vez hecha la actualización ejecutar los siguientes comandos: 
```bash
docker-compose -f latest.yml exec portal bash
cd /usr/lib/ckan/default/src/ckanext-gobar-theme
/usr/lib/ckan/default/bin/paster --plugin=ckan reupload-resources-files --config=/etc/ckan/default/production.ini
exit
```

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
