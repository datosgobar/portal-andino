FROM solr:6.0
MAINTAINER Jose A. Salgado<jose.salgado.wrk@gmail.com>

# Variables de Entorno
ENV SOLR_CORE ckan
ENV SOLR_PORT 8983

# User
USER root

# Creamos los directorios necesarios para Solr
RUN mkdir -p /opt/solr/server/solr/$SOLR_CORE/conf
RUN mkdir -p /opt/solr/server/solr/$SOLR_CORE/data

# 
ADD ./requiere/solrconfig.xml \
https://raw.githubusercontent.com/ckan/ckan/ckan-2.5.2/ckan/config/solr/schema.xml \
https://raw.githubusercontent.com/apache/lucene-solr/releases/lucene-solr/6.0.0/solr/server/solr/configsets/basic_configs/conf/currency.xml \
https://raw.githubusercontent.com/apache/lucene-solr/releases/lucene-solr/6.0.0/solr/server/solr/configsets/basic_configs/conf/synonyms.txt \
https://raw.githubusercontent.com/apache/lucene-solr/releases/lucene-solr/6.0.0/solr/server/solr/configsets/basic_configs/conf/stopwords.txt \
https://raw.githubusercontent.com/apache/lucene-solr/releases/lucene-solr/6.0.0/solr/server/solr/configsets/basic_configs/conf/protwords.txt \
https://raw.githubusercontent.com/apache/lucene-solr/releases/lucene-solr/6.0.0/solr/server/solr/configsets/data_driven_schema_configs/conf/elevate.xml \
/opt/solr/server/solr/$SOLR_CORE/conf/

# Crear Core
RUN echo name=$SOLR_CORE > /opt/solr/server/solr/$SOLR_CORE/core.properties
ADD ./requiere/schema.xml /etc/solr/conf/schema.xml

# Correccion de permisos para Solr
RUN chown -R $SOLR_USER:$SOLR_USER /opt/solr/server/solr/$SOLR_CORE

EXPOSE $SOLR_PORT