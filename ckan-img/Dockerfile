FROM ubuntu:14.04.1
MAINTAINER Leandro Gomez<lgomez@devartis.com>

WORKDIR /app

ENV CKAN_DIST_MEDIA=/usr/lib/ckan/default/src/ckanext-gobar-theme/ckanext/gobar_theme/public/user_images \
    CKAN_DIST_CONFIG=/var/lib/ckan/theme_config \
    DEBIAN_FRONTEND=noninteractive \
    CKAN_APACHE2_PORT=80 \
    CKAN_DATAPUSHER_PORT=8800 \
    CKAN_NGINX_PORT=8080 \
    HOME=/root \
    CKAN_VERSION=2.5.1 \
    CKAN_DATA=/var/lib/ckan \
    CKAN_INIT=/etc/ckan_init.d \
    DATAPUSHER_HOME=/usr/lib/ckan/datapusher \
    CKAN_HARVEST_GCF=/var/log/ckan/std
ENV GOBAR_CONFIG $(cat ./config/default.json)

RUN apt-get -y update && \
      apt-get install -y software-properties-common && \
      add-apt-repository ppa:ansible/ansible && \
      apt-get update -y && apt-get install ansible -y && \
      apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./site.yml /app/
COPY ./roles /app/roles
COPY ./group_vars /app/group_vars
RUN  ansible-playbook -i "localhost," -c local site.yml --tags "dependencies"
RUN  ansible-playbook -i "localhost," -c local site.yml --skip-tags "dependencies"

CMD ["/usr/bin/supervisord"]
CMD ["/etc/ckan_init.d/start_ckan.sh"]

VOLUME $CKAN_DATA $CKAN_DIST_MEDIA $CKAN_DIST_CONFIG

# 80:NGINX 8800:DATAPUSHER
EXPOSE $CKAN_APACHE2_PORT $CKAN_DATAPUSHER_PORT
