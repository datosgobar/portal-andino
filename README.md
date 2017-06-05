# Portal Andino

[![Build Status](https://travis-ci.org/datosgobar/portal-andino.svg?branch=master)](https://travis-ci.org/datosgobar/portal-andino)

[![Docs Status](https://readthedocs.org/projects/portal-andino/badge/?version=master)](http://portal-andino.readthedocs.io/es/master/)

Implementación de CKAN en Docker, desarrollada en el contexto del portal distribuible Andino.

También podés [ver el repositorio del tema visual](https://github.com/datosgobar/portal-andino-theme).

## Índice

+ [Qué contiene el paquete de Andino](#qué-contiene-el-paquete-de-andino)
+ [Instalación](#instalación)
+ [Migración](#migración)
+ [Uso](#uso)
+ [Créditos](#créditos)
+ [Contacto](#contacto)

## Qué contiene el paquete de Andino

+ [CKAN 2.5.2](http://docs.ckan.org/en/ckan-2.5.2/)
+ [Datastore](http://docs.ckan.org/en/latest/maintaining/datastore.html)
+ [FileStore](http://docs.ckan.org/en/latest/maintaining/filestore.html)
+ [Datapusher](https://github.com/ckan/datapusher)
+ [Hierarchy](https://github.com/datagovuk/ckanext-hierarchy)
+ [datajsonAR](https://github.com/datosgobar/ckanext-datajsonAR)
+ [Harvest](https://github.com/ckan/ckanext-harvest)
+ [Portal Andino theme](https://github.com/datosgobar/portal-andino-theme)
+ [Apache2 & NginX](http://docs.ckan.org/en/ckan-2.5.2/maintaining/installing/deployment.html#install-apache-modwsgi-modrpaf)


### Dependencias

+ DOCKER: [Guía de instalación](https://docs.docker.com/engine/installation).
+ Docker Compose: [Guía de instalación](https://docs.docker.com/compose/install/)

### ¿Qué contenedores vas a instalar?

+ Andino:
  + Packages | Service:
    + Imagen base: ubuntu xenial 14.04
    + Apache 2 | WSGI MOD
    + CKAN 2.5.3
  + Plugins:
    + DataStore
    + FileStore
    + Datapusher
    + DataJSONAR
    + Andino Theme
    + Harvest
    + Hierarchy
+ Nginx:
  + Package | Service:
    + Imagen base: `nginx:1.11.9`
    + Nginx 1.11
  + Modificaciones:
    + Configuración para caché de CKAN
+ Postfix:
  + Package | Service:
    + Imagen base: `ubuntu:trusty`
    + Postfix
+ Redis:
  + Package | Service:
    + Imagen base: `alpine:3.5`
    + Redis: 2.3.7
+ PostgreSQL:
  + Packages | Service:
    + Imagen base: `debian:jessie`
    + PostgreSQL 9.5
+ Solr:
  + Package | Service
    + Imagen base: `solr:6.0`
    + Solr 6.0
  + Plugins:
    + CKAN_Schema 2.2+(Hierarchy-Mig)

---

## Instalación

Ver documentación de [instalación](http://portal-andino.readthedocs.io/es/master/setup/install/)

## Migración

Ver documentación de [migración](http://portal-andino.readthedocs.io/es/master/setup/migration/)

## Uso

Ver la documentacion [uso](http://portal-andino.readthedocs.io/es/master/setup/usage/)


## Créditos

Este trabajo está inspirado en el desarrollo hecho por:

+ [CKAN.org](https://github.com/ckan/ckan/)
+ [Eccenca](https://github.com/eccenca/ckan-docker)

## Consultas sobre Andino

**Andino es un portal abierto en constante desarrollo** para ser usado por toda la comunidad de datos. Por eso, cuando incorporamos una nueva mejora, **cuidamos mucho su compatibilidad con la versión anterior**.

Como la comunidad de datos es grande, **por ahora no podemos dar soporte técnico frente a modificaciones particulares del código**. Sin embargo, **podés contactarnos para despejar dudas**. 

## Contacto

Te invitamos a [crearnos un issue](https://github.com/datosgobar/portal-andino-theme/issues/new?title=Encontre%20un%20bug%20en%20nombre-del-repo) en caso de que encuentres algún bug o tengas feedback de alguna parte de `portal-andino-theme`.

Para todo lo demás, podés mandarnos tu comentario o consulta a [datos@modernizacion.gob.ar](mailto:datos@modernizacion.gob.ar).

