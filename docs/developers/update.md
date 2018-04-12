<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Actualización](#actualizaci%C3%B3n)
    - [Versiones 2.x](#versiones-2x)
        - [Actualización simple](#actualizaci%C3%B3n-simple)
        - [Actualización avanzada](#actualizaci%C3%B3n-avanzada)
    - [Versiones 1.x a 2.x](#versiones-1x-a-2x)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Actualización

## Versiones 2.x

### Actualización simple

Si instalamos la aplicación con la última versión del instalador ([este](https://raw.github.com/datosgobar/portal-andino/master/install/install.py)).
El mismo no requiere parámetros, pero contiene algunos opcionales:

    # Parametros de install.py
    [-h]                    Mostrar la ayuda del script
    [--install_directory INSTALL_DIRECTORY]
        Directorio donde esta instalada la aplicacion.
        Por defecto es `/etc/portal`

Para esta actualización de ejemplo usaremos los valores por defecto:

    sudo wget https://raw.github.com/datosgobar/portal-andino/master/install/update.py
    sudo python update.py

De esta forma el script asumirá que instalamos la aplicacion en `/etc/portal`.

### Actualización avanzada

Si instalamos la aplicacion en otro directorio distinto de `/etc/portal`, necesitamos correr el script de una manera diferente.
Suponiendo que instalamos la aplicacion en `/home/user/app/`, debemos correr los siguientes pasos:

    wget https://raw.github.com/datosgobar/portal-andino/master/install/update.py
    sudo python update.py --install_directory="/home/user/app/"

## Versiones 1.x a 2.x

Ver documento de [migración](migration.md)
