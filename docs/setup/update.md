# Actualización - Portal Andino

## Versiones 2.x

### Actualización simple

Si instalamos la aplicacion con la ultima version del instalador ([este](https://raw.github.com/datosgobar/portal-andino/master/install/install.py)),
simplemente basta con correr:


    python -c "$(wget -O - https://raw.github.com/datosgobar/portal-andino/master/install/update.py)"


De esta forma el script asumira que instalamos la aplicacion en `/etc/andino`.


### Actualización avanzada

Si instalamos la aplicacion en otro directorio distinto de `/etc/andino`, necesitamos correr el scrip de una manera diferente.
Suponiendo que instalamos la aplicacion en `/home/user/app/`, debemos correr los siguientes pasos:


```bash

wget https://raw.github.com/datosgobar/portal-andino/master/install/update.py

python update.py --install_directory="/home/user/app/"

```

El script correra hara un par de cambios sobre el directorio. Entre los cambios, se encuentran:
- Renombre de latest.yml a docker-compose.yml
- Se agrega el script `andino-ctl` para manejo de la aplicacion

En este caso para poder usar el script `andino-ctl`, debemos usar la variable de entorno `OVERWRITE_APP_DIR`:

    env OVERWRITE_APP_DIR=/home/user/app andino-ctl

## Versiones 1.x a 2.x
