# Historial de versiones - Andino

## Indice

- [2.6.0](#260---2019-09-03)
- [2.5.6](#256---2019-04-09)
- [2.5.5](#255---2019-02-20)
- [2.5](#25---actual)
- [2.4](#24---2018-06-14)
- [2.3](#23---2018-02-21)
- [2.2](#22---2018-01-09)
- [2.1](#21---2017-07-13)
- [2.0](#20---2017-07-03)


## 2.6.0 - 2019-09-03

* Actualización a CKAN 2.7.6.
* Generación automática de un id default para series de tiempo en el formulario de recursos.
* Implementación de un JSON con los valores a utilizar en el campo _Unidades de medida_.
* Modificación al script de actualización para obligar al usuario a que haya un sitehost definido.
* Se agregó "blog" como red social.
* Actualización del funcionamiento de la búsqueda de datasets destacados.
* Actualización del diseño de la pantalla de login.
* Fix del funcionamiento del botón "VOLVER" en el formulario de creación de recursos.
* Implementación del [plugin ckanext-security](https://github.com/data-govt-nz/ckanext-security).
* Implementación del [plugin ckanext-xloader](https://github.com/ckan/ckanext-xloader).


## 2.5.6 - 2019-04-09

* Mejora de performance en la página de búsqueda de datasets.
* Implementación de persistencia de cronjobs en la actualización de instancias de Andino.
* Mejoras en la previsualización de recursos. 
* Actualización del cronjob de la subida automática diaria de recursos al Datastore para que se cree también una vista.
* Actualización del formulario de datasets para poder guardar un dataset en borrador sin necesidad de crear un recurso.
* Implementación de un archivo JSON donde se guardan las licencias a utilizar en el portal, y de un campo en el archivo 
de configuración donde se especifica su path.
* Parametrización del tamaño máximo de archivos para recursos en la instalación y actualización de instancias de Andino.
* Parametrización del nombre de dominio en la actualización de instancias de Andino.
* Actualización de un header de la configuración SSL de Nginx (X-Forwarded-Protocol -> X-Forwarded-Proto).


## 2.5.5 - 2019-02-20

* Implementación de un comando de CKAN que toma todos los recursos locales del portal que cumplan determinadas 	
condiciones e intenta resubirlos para recuperar los archivos perdidos en versiones anteriores de Andino por el problema 	
mencionado en el item anterior.	
* Se eliminaron los plugins `harvest` y `datajson` de la configuración de Andino y se creó una migración para lograr 	
tal efecto durante la actualización de una instancia debido a posibles problemas al instalar una nueva.   	
* Correción del comportamiento correspondiente al botón que permite seleccionar y subir un archivo para un recurso en 	
el formulario de creación/edición de recursos.
* Utilización de un criterio para decidir en qué casos especificar (o no) el número de puerto de Andino en el archivo 
de configuración (se evita la especificación de los puertos default: 80 para HTTP y 443 para HTTPS).
* Implementación de estrategia para decidir la versión a utilizar de portal-base en el Dockerfile de portal-andino; se 
permite especificar un nombre al realizar un `docker build` y, en caso de no especificar ninguno, se utilizará una 
versión default.
* Implementación de comandos en el archivo `dev.sh` para instalar y actualizar una instancia de Andino con fines de 
desarrollo.
* Aumento en el tamaño del nombre de la versión mostrada en la interfaz de Andino.
* Actualización del plugin series-tiempo-ar-explorer a 2.0.2.


## 2.5 - Actual

* Corrección del formulario de creación/edición de recursos para mantener guardado un archivo al editar un recurso sin 
modificar el campo correspondiente.
* Implementación de sección dentro de la configuración del portal en la interfaz para activar el croneo de la subida 
automática diaria de recursos al Datastore mediante un comando de Datapusher. 
* Creación del campo _"Nombre del enlace"_ en las secciones personalizadas del Acerca para que el portal utilice como URL.
* Modificación de la URL definida para el botón "VOLVER" en el formulario de creación/edición de recursos.
* Se implementó el reinicio de los workers de supervisor al instalar o actualizar Andino.
* Modificación en el guardado del campo `ckan.site_url` en el archivo de configuración que especifica el schema y el 
número de puerto de la URL del portal durante su instalación y actualización.
* Documentación de comando de Datapusher para subir todos los recursos al Datastore.
* Testeo de instalación y actualización de Andino durante los builds de Travis.
* Utilización de GitHub Webhooks para el mecanismo de deploy.
* Implementación de secciones dentro de la configuración del portal en la interfaz para activar la integración con 
Google Dataset Search y definir el id de Google Tag Manager.
* Implementación de certificados SSL en Andino mediante configuraciones en el contenedor de Nginx que corre de forma 
paralela al contenedor del portal (la implementación anterior queda deprecada).
* Reinicio de Nginx luego de instalar o actualizar Andino; luego, se espera hasta que el contenedor responda u ocurran 
5 minutos.
* Implementación del explorador de series de tiempo en Andino.
* Creación de suite de tests para portal-andino-theme (datasets, recursos, data.json, configuraciones varias).
* Se agrega LinkedIn como red social en la configuración del portal.
* Optimización del manejo y búsqueda en la pantalla de organizaciones.
* Modificación en la pantalla de organizaciones que le cambia el título a las suborganizaciones de texto puro a una URL.
* Implementación del plugin `dcat`.
* Creación de plugin template que sirva como base para añadir funcionalidades a Andino.
* Corrección de visibilidad del campo _"Nombre del archivo"_ en el formulario de creación/edición de recursos.
* Corrección de visibilidad del botón que limpia la URL de un recurso.
* Corrección de visibilidad de la descripción de cada dataset en la pantalla de datasets para casos en los que existan 
varias líneas de texto.
* Especificación del timezone en la instalación de Andino.
* Implementación de caché configurable para el portal.
* Modificación en la pantalla de inicio de sesión para que aparezca un error si las credenciales son incorrectas en 
lugar de redirigir a la home sin aviso alguno.
* Documentación de uso del plugin de CORS para posibilitar la navegación en Andino utilizando la IP sin que existan 
errores de Javascript.
* Guardado de información de datasets que se pierde en el proceso de federación.
* Se agrega la licencia _Creative Commons Attribution 4.0_ y se la utiliza como default.
* Generación del `data.json` y `catalog.xlsx` al instalar Andino.


## 2.4 - 2018-06-14

* Migración a la versión 2.7.4 de CKAN.
* Implementación de hook para limpieza de la caché
* Implementación del servicio `supervisor` para la utilización de workers que lleven a cabo tareas asincrónicas.
* Implementación de lógica para la creación/actualización del `data.json` y `catalog.xlsx` dentro de 
portal-andino-theme (el plugin ckanext-datajsonar queda deprecado) mediante el uso de los workers de supervisor y 
tareas de RQ.
  * La regeneración de dichos archivos se ve disparada ante cada cambio en los metadatos del portal, sus datasets, 
  recursos, o temas.
* Parametrización en el archivo de configuración para la opacidad de la portada de Andino (`andino.background_opacity`).
* Actualización de validaciones para los metadatos de recursos para evitar errores durante la carga.
* Implementación de certificados SSL mediante un contenedor de Nginx que corre en el host de Andino.
* Mejoras en la visualización de los botones del header del portal.
* Implementación de la sección _"Acerca"_ en la configuración del portal.
  * Nueva funcionalidad: creación de secciones personalizadas.
* Implementación de la sección _"APIs"_ (landing de APIs) en la configuración del portal.
  * La landing contendrá todos los recursos de tipo API.
* Aumento de la robustez de la búsqueda de información perteneciente a datasets y recursos en los templates del portal.
* Se vuelve a permitir la edición manual del campo _"URL"_ de un recurso en el formulario de creación.
* Utilización de un archivo de configuración guardado en Redis para evitar problemas cuando los procesos de Apache 
necesitan leer la configuración del portal.
* Parametrización del _from_ de los mails enviados por Andino.
* Mejoras en la visualización de la tabla de metadatos mostrada en la pantalla de recursos.


## 2.3 - 2018-02-21

* Correcciones en el guardado de campos en el `data.json`.
* Correcciones en la pantalla de visualización de datasets y recursos.
* Creación de una tabla que muestra los metadatos de un recurso en su pantalla de visualización.
* Agregado de campos faltantes en los datasets, recursos y los metadatos del portal (dentro de su configuración en la 
interfaz).
* Implementación de la creación de un archivo Excel con los datos del catálogo (`catalog.xlsx`).
* Corrección de error provocado al intentar borrar recursos no encontrados en el Datastore.
* Modificación en el campo _"Página de referencia"_ para que el valor se genere automáticamente.
* Correcciones en los botones de la página de vistas de los recursos.


## 2.2 - 2018-01-09

* Validaciones para campos pertenecientes a la configuración del portal, datasets y recursos.
* Modificación del formulario de creación/edición de recursos para que no se pueda guardar un recurso sin título.


## 2.1 - 2017-07-13

* Integración del plugin de Google Analytics.
* Corrección de errores al intentar ingresar al formulario de edición de datasets.


## 2.0 - 2017-07-03

* Implementación del borrado físico de datasets, recursos, organizaciones y temas.
* Validaciones para campos de tipo texto en formularios.
* Implementación del borrado de datasets en borrador.
* Visualización de la versión del plugin en la interfaz.
* Mejoras en las traducciones para la interfaz.
* Corrección de la pérdida de la configuración correspondiente al portal al reiniciar Apache (se guardan los datos en 
una variable de Pylons en lugar de utilizar variables de entorno).
* Parametrización de los puertos de Nginx y del Datastore en el host durante la instalación de Andino.
* Generación de imágenes de Andino desde Travis realizadas sólo si el build fue terminado con éxito.
