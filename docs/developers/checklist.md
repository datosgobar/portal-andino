<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Indice

- [Recomendaciones para la puesta en producción de una instancia de Andino](#recomendaciones-para-la-puesta-en-produccion-de-una-instancia-de-andino)
  - [Verificá que tu instancia de Andino tenga un nombre de dominio único y bien configurado](#verifica-que-tu-instancia-de-andino-tenga-un-nombre-de-dominio-unico-y-bien-configurado)
    - [Verificar si mi Andino tiene el nombre de dominio configurado correctamente](#verificar-si-mi-andino-tiene-el-nombre-de-dominio-configurado-correctamente)
    - [Actualizando el nombre de dominio asignado a Andino](#actualizando-el-nombre-de-dominio-asignado-a-andino)
  - [Verificá que el contenedor portal pueda resolver el nombre de dominio asignado a la instancia](#verifica-que-el-contenedor-portal-pueda-resolver-el-nombre-de-dominio-asignado-a-la-instancia)
  - [Seguir las recomendaciones de seguridad](#seguir-las-recomendaciones-de-seguridad)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Recomendaciones para la puesta en producción de una instancia de Andino

Si estás por configurar tu instancia de Andino para un ambiente productivo, tenemos algunas recomendaciones para que sigas y verifiques si tu instancia está bien configurada.

## Verificá que tu instancia de Andino tenga un nombre de dominio único y bien configurado

Para el correcto funcionamiento de tu instancia de Andino, es recomendable que la misma tenga un único nombre de dominio asignado.

Una vez que tengas definido el nombre de dominio (ej: `datos.ministerio.gob.ar`) y el mismo se resuelva a la IP pública asignado al _host_ de tu Andino (o al _load balancer_/_frontend server_ que opcionalmente tengas) es importante que tu instancia de Andino conozca ese nombre de dominio y que esté configurado para responder al mismo.

### Verificar si mi Andino tiene el nombre de dominio configurado correctamente

Para saber si tu instancia de Andino tiene el nombre de dominio correctamente configurado seguí los siguientes pasos, ejecutando el comando en el directorio de instalación de Andino (ej: `/etc/portal`):

    docker-compose -f latest.yml exec portal grep ckan\.site_url /etc/ckan/default/production.ini

Si tu sitio está bien configurado, el valor del parámetro de configuración `ckan.site_url` deberá coincidir con el nombre de dominio de tu Andino (incluyendo el _schema_, `http` o `https`):

    ckan.site_url=http://datos.ministerio.gob.ar/

Si éste no coincide, deberás modificar el valor del parámetro en la configuración de tu Andino.

### Actualizando el nombre de dominio asignado a Andino

Para actualizar el nombre de dominio que tiene tu andino (por ejemplo `datos.ministerio.gob.ar`) debés ejecutar el siguiente comando:

    docker-compose -f latest.yml exec portal /etc/ckan_init.d/update_conf.sh "ckan.site_url=http://datos.ministerio.gob.ar/";


## Verificá que el contenedor portal pueda resolver el nombre de dominio asignado a la instancia

Para asegurar el correcto funcionamiento de algunos componentes de la arquitectura de Andino, es necesario que desde dentro de los contenedores Docker que forman parte de la solución, el nombre de dominio asignado a tu Andino pueda ser resuelto correctamente.

La verificación de tal condición está documentada en la sección [DNS](dns.md).

## Seguir las recomendaciones de seguridad

La presente documentación contiene un apartado acerca de recomendaciones de seguridad. Por favor [leelas y seguí las recomendaciones](maintenance.md#recomendaciones-de-seguridad-y-optimizaciones).
