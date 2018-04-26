<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Configuración de DNS](#configuracion-de-dns)
    - [Introducción](#introduccion)
    - [Cómo diagnosticar si tu andino tiene el problema](#como-diagnosticar-si-tu-andino-tiene-el-problema)
    - [Cómo resolver el problema](#como-resolver-el-problema)
        - [Configuración de DNS públicos](#configuracion-de-dns-publicos)
        - [Configurar andino con el nuevo nombre de dominio](#configurar-andino-con-el-nuevo-nombre-de-dominio)
        - [Configurar el DNS del portal andino](#configurar-el-dns-del-portal-andino)
        - [Verificando que el problema fue resuelto](#verificando-que-el-problema-fue-resuelto)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Configuración de DNS

## Introducción

Algunas pantallas del Portal Andino requieren que la aplicación web pueda navegar sin restricciones desde el proceso en el cual corre la aplicación Python a la URL donde está publicada el sitio (definida por el setting `ckan.site_url`).

Esta URL debe poder ser accedida sin problemas de resolución de nombres o de ruteo de IPs desde el mismo contenedor _portal_ para el correcto funcionamiento del sitio.

Recordá que _todos los comandos de este artículo deben ser ejecutados en el directorio donde instalaste andino, por ejemplo `/etc/portal`._


## Cómo diagnosticar si tu andino tiene el problema

Para saber si es necesario realizar las configuraciones detalladas en este artículo, podés realizar los siguientes pasos detallados abajo.

1. Obtener el valor de `ckan.site_url`: el valor se puede obtener ejecutando el siguiente comando: `sudo docker-compose -f latest.yml exec portal grep ckan\.site_url /etc/ckan/default/production.ini`. Ese comando debería devolver `ckan.site_url = <URL de tu Andino>`.
2. Evaluar si tu andino puede navegar hasta la URL del sitio. Ejecutá el siguiente comando: `sudo docker-compose -f latest.yml exec portal curl <URL de tu Andino>/data.json`.

Si el segundo paso no devuelve una respuesta en formato _json_ con la información del catálogo de tu instancia idéntica a la que obtendrías navegando desde tu navegador a `<URL de tu Andino>/data.json` (por ejemplo, luego de un rato obtenés `curl: (7) Failed to connect to <URL de tu Andino> port 80: Connection timed out`), entonces _debés aplicar la configuración recomendada en este artículo_.

## Cómo resolver el problema

La solución del problema se basa en configurar un nombre de dominio a tu portal andino, configurando los DNS públicos para que resuelvan a la IP pública de tu instancia y configurar el DNS del contenedor `portal` de tu andino para que resuelva a la IP interna.

### Configuración de DNS públicos

Este paso no está cubierto por esta documentación, ya que puede ser resuelto mediante formas diversas, dependiendo de la infraestructura con la que contás.

Lo que debés hacer es contactarte con tu administrador de infraestructura y solicitar una IP pública fija y un nombre de dominio para la instancia de tu andino.

Probablemente ya tengas un nombre de dominio asignado a tu instancia de andino, con lo cual podés saltar este paso.

### Configurar andino con el nuevo nombre de dominio

Si ya tenés un nombre de dominio asignado para acceder a tu andino y cuando lo instalaste lo configuraste usando ese nombre de dominio, podés saltar este paso.

Para configurar el nuevo nombre de dominio es necesario actualizar el setting `ckan.site_url` de la instancia de Andino. Esto lo podés lograr con el siguiente comando:

`sudo docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "ckan.site_url=http://<tu nombre de dominio>"`.

Podés verificar que haya quedado bien configurado ejecutando:

`sudo docker-compose -f latest.yml exec portal grep ckan\.site_url /etc/ckan/default/production.ini`.

Para reflejar los cambios es neceario reiniciar la aplicación web del contenedor `portal`:

`sudo docker-compose -f latest.yml exec portal apachectl restart`.

Finalmente, si ya tenías datos cargados en tu andino, necesitás regenerar el índice de búsqueda, usando el siguiente comando:

`sudo docker-compose -f latest.yml exec portal /etc/ckan_init.d/run_rebuild_search.sh`

### Configurar el DNS del portal andino

Si aún teniendo un DNS asignado, tu portal no puede resolver el nombre de dominio a la IP pública del servidor, podés modificar la configuración del servidor para que resuelva el nombre de dominio a la IP privada.

El objetivo de este paso es agregar en el archivo `/etc/hosts` del contenedor _portal_ una entrada que mapee el nombre de dominio asignado a tu instancia de andino a la IP interna del servidor o a _127.0.0.1_.

Para realizar esto podés ejecutar el siguiente comando:

`sudo docker-compose -f latest.yml exec portal vi /etc/hosts`

Y editar el archivo agregando esta línea al final:

`127.0.0.1  <la URL de tu andino sin http://>`

### Verificando que el problema fue resuelto

Si el problema fue resuelto, ahora podrías realizar el procedimiento detallado en [Cómo diagnosticar si tu andino tiene el problema](#c%C3%B3mo-diagnosticar-si-tu-andino-tiene-el-problema) y deberías obtener un _json_ como respuesta.
