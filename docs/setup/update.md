# Actualización - Portal Andino

## Versiones 2.x

### Actualización simple

Si instalamos la aplicacion con la ultima version del instalador ([este](https://raw.github.com/datosgobar/portal-andino/master/install/install.py)).
El mismo no requiere parametros, pero contiene algunos opcionales:

```bash
# Parametros de install.py
    [-h]                    Mostrar la ayuda del script
    [--andino_version ANDINO_VERSION]
        Version de andino que se desea instalar. Por defecto instalara la version del archivo
        `stable_version.txt` en el repositorio. Se pueden pasar valores como: `latest`, `release-2.3.0`
    [--install_directory INSTALL_DIRECTORY]
        Directorio donde esta instalada la aplicacion.
        Por defecto es `/etc/portal`

```

Para esta actualización de ejemplo usaremos los valores por defecto:

    sudo python -c "$(wget -O - https://raw.github.com/datosgobar/portal-andino/master/install/update.py)"


De esta forma el script asumirá que instalamos la aplicacion en `/etc/portal`.


### Actualización avanzada

Si instalamos la aplicacion en otro directorio distinto de `/etc/portal`, necesitamos correr el script de una manera diferente.
Suponiendo que instalamos la aplicacion en `/home/user/app/`, debemos correr los siguientes pasos:


```bash

wget https://raw.github.com/datosgobar/portal-andino/master/install/update.py

sudo python update.py --install_directory="/home/user/app/"

```


## Versiones 1.x a 2.x

Ver documento de [migracion](docs/setup/migration.md)
