<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Indice

- [Configuración de DNS](#configuracion-de-dns)
  - [Introducción](#introduccion)
  - [Cómo diagnosticar si tu andino tiene el problema](#como-diagnosticar-si-tu-andino-tiene-el-problema)
  - [Cómo resolver el problema](#como-resolver-el-problema)
    - [Configuración de DNS públicos](#configuracion-de-dns-publicos)
    - [Configurar andino con el nuevo nombre de dominio](#configurar-andino-con-el-nuevo-nombre-de-dominio)
    - [Configurar un alias en la red de Docker para el contenedor nginx](#configurar-un-alias-en-la-red-de-docker-para-el-contenedor-nginx)
    - [Verificando que el problema fue resuelto](#verificando-que-el-problema-fue-resuelto)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Configuración de DNS

## Introducción

Algunas funcionalidades del Portal Andino requieren que la aplicación web o procesos externos (ej: DataPusher) puedan navegar sin restricciones desde el proceso en el cual corre la aplicación Python a la URL donde está publicado el sitio (definida por el setting `ckan.site_url`).

Esta URL debe poder ser accedida sin problemas de resolución de nombres o de ruteo de IPs desde el mismo contenedor _portal_ para el correcto funcionamiento del sitio.

Algunas instancias de Andino han reportado problemas de funcionamiento debido a que la infraestructura donde están alojados no permite esta resolución de nombres de manera correcta. Este artículo describe cómo diagnosticar el problema y propone soluciones al mismo.

Recordá que _todos los comandos de este artículo deben ser ejecutados en el directorio donde instalaste andino, por ejemplo `/etc/portal`._


## Cómo diagnosticar si tu andino tiene el problema

Para saber si es necesario realizar las configuraciones detalladas en este artículo, podés realizar los siguientes pasos detallados abajo.

1. Obtener el valor de `ckan.site_url`: el valor se puede obtener ejecutando el siguiente comando: `docker-compose -f latest.yml exec portal grep ckan\.site_url /etc/ckan/default/production.ini`. Ese comando debería devolver `ckan.site_url = <URL de tu Andino>`.
2. Evaluar si tu andino puede navegar hasta la URL del sitio. Ejecutá el siguiente comando: `docker-compose -f latest.yml exec portal curl <URL de tu Andino>/data.json`.

Si el segundo paso no devuelve una respuesta en formato _json_ con la información del catálogo de tu instancia idéntica a la que obtendrías navegando desde tu navegador a `<URL de tu Andino>/data.json` (por ejemplo, luego de un rato obtenés `curl: (7) Failed to connect to <URL de tu Andino> port 80: Connection timed out`), entonces _debés aplicar la configuración recomendada en este artículo_.

## Cómo resolver el problema

La solución del problema se basa en asegurar que dentro de la red de Docker el nombre de dominio de Andino pueda resolverse correctamente a la IP pública del host, a la IP privada dentro de la red en la que está o a la IP interna dentro de la red de Docker.

Para lograrlo, planteamos distintas alternativas.

### Configuración de DNS públicos

Este paso no está cubierto por esta documentación, ya que puede ser resuelto mediante formas diversas, dependiendo de la infraestructura con la que contás.

Lo que debés hacer es contactarte con tu administrador de infraestructura y solicitar una IP pública fija y un nombre de dominio para la instancia de tu andino.

Probablemente ya tengas un nombre de dominio asignado a tu instancia de andino, con lo cual podés saltar este paso.

### Configurar andino con el nuevo nombre de dominio

Si ya tenés un nombre de dominio asignado para acceder a tu andino, y cuando lo instalaste lo configuraste usando ese nombre de dominio, podés saltar este paso.

Para configurar el nuevo nombre de dominio es necesario actualizar el setting `ckan.site_url` de la instancia de Andino. Esto lo podés lograr con el siguiente comando:

`docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "ckan.site_url=http://<tu nombre de dominio>"`.

Podés verificar que haya quedado bien configurado ejecutando:

`docker-compose -f latest.yml exec portal grep ckan\.site_url /etc/ckan/default/production.ini`.

Para reflejar los cambios, es neceario reiniciar la aplicación web del contenedor `portal`:

`docker-compose -f latest.yml exec portal apachectl restart`.

Finalmente, si ya tenías datos cargados en tu andino, necesitás regenerar el índice de búsqueda, usando el siguiente comando:

`docker-compose -f latest.yml exec portal /etc/ckan_init.d/run_rebuild_search.sh`

### Configurar un alias en la red de Docker para el contenedor nginx

Si, aún teniendo un nombre de dominio asignado, tu portal no puede resolver el mismo a la IP pública del servidor, podés modificar la configuración de la red de Docker usada por Andino para mapear el nombre de dominio de tu instancia al contenedor `nginx`.

Acalaración: Esta configuración se realiza por defecto para todas las instancias de Andino desde la versión 2.5. Si tu instancia de Andino fue creada *antes de la versión 2.5*, seguramente quieras realizar estos pasos.

Para asegurarte de que la red interna de los contenedores de Docker que conforman Andino tienen la configuración necesaria para la correcta resolución de nombres, podés seguir los siguientes pasos (todos en el directorio de instalación de Andino, por ejemplo `/etc/portal`):

1. Editá el archivo `.env` y asegurate que el valor del atributo `SITE_HOST` tenga el valor del _hostname_ de tu instancia de Andino, sin _http_. Si no encontrás una entrada para `SITE_HOST` en tu archivo `.env`, agregala al final. Por ejemplo debería ser `SITE_HOST=mi-andino.mi-ministerio.gob.ar`.
1. Descargá la última versión de `latest.yml`: `mv latest.yml latest.yml.bak && wget https://raw.githubusercontent.com/datosgobar/portal-andino/master/latest.yml`. Probablemente ya tengas esta misma versión si actualizaste a Andino 2.5, pero para asegurarnos de que tengas los últimos cambios necesarios para esta configuración es necesario realizar este paso.
2. Recreá el contenedor `nginx`: `docker-compose -f latest.yml up -d nginx`. Recordá que este paso puede generar algo de _downtime_, por lo que quizás sea prudente realizarlo en algún horario con poco tráfico en Andino.

### Verificando que el problema fue resuelto

Si el problema fue resuelto, ahora podrías realizar el procedimiento detallado en [Cómo diagnosticar si tu andino tiene el problema](#como-diagnosticar-si-tu-andino-tiene-el-problema) y deberías obtener un _json_ como respuesta.
