FROM ubuntu:14.04.1
MAINTAINER Leandro Gomez<lgomez@devartis.com>

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive \
    CKAN_APACHE2_PORT=8080 \
    CKAN_DATAPUSHER_PORT=8800 \
    CKAN_VERSION=2.5.1 \
    CKAN_HOME=/usr/lib/ckan/default \
    CKAN_DIST_MEDIA=/usr/lib/ckan/default/src/ckanext-gobar-theme/ckanext/gobar_theme/public/user_images \
    CKAN_DATA=/var/lib/ckan \
    CKAN_DIST_CONFIG=/var/lib/ckan/theme_config

RUN apt-get -y update && \
      apt-get install -y software-properties-common && \
      add-apt-repository ppa:ansible/ansible && \
      apt-get update -y && apt-get install ansible -y && \
      apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./site.yml /app/
COPY ./roles /app/roles
COPY ./group_vars /app/group_vars
RUN  ansible-playbook -i "localhost," -c local site.yml -vv

CMD ["/etc/ckan_init.d/start_ckan.sh"]

VOLUME $CKAN_DATA $CKAN_DIST_MEDIA $CKAN_DIST_CONFIG

# 8080:APACHE 8800:DATAPUSHER
EXPOSE $CKAN_APACHE2_PORT $CKAN_DATAPUSHER_PORT
