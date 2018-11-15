<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Actualización](#actualizaci%C3%B3n)
  - [Versiones 2.x](#versiones-2x)
    - [Actualización simple](#actualizaci%C3%B3n-simple)
    - [Actualización avanzada](#actualizaci%C3%B3n-avanzada)
    - [Problemas comunes](#problemas-comunes)
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
