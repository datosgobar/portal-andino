FROM datosgobar/portal-base:release-0.7.1
MAINTAINER Leandro Gomez<lgomez@devartis.com>

ARG PORTAL_VERSION
ENV CKAN_HOME /usr/lib/ckan/default
ENV CKAN_DIST_MEDIA /usr/lib/ckan/default/src/ckanext-gobar-theme/ckanext/gobar_theme/public/user_images
ENV CKAN_DEFAULT /etc/ckan/default

WORKDIR /portal
RUN $CKAN_HOME/bin/pip install -e git+https://github.com/datosgobar/portal-andino-theme.git@222236bab329a6d6a7d0d4b0bc3dcc2bd6fc5de5#egg=ckanext-gobar_theme
RUN mkdir -p $CKAN_DIST_MEDIA
RUN chown -R www-data:www-data $CKAN_DIST_MEDIA
RUN chmod u+rwx $CKAN_DIST_MEDIA
RUN echo "$PORTAL_VERSION" > /portal/version

VOLUME $CKAN_DIST_MEDIA $CKAN_DEFAULT

