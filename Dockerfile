FROM datosgobar/portal-base:development
MAINTAINER Leandro Gomez<lgomez@devartis.com>

ENV CKAN_HOME /usr/lib/ckan/default
ENV CKAN_DIST_MEDIA /usr/lib/ckan/default/src/ckanext-gobar-theme/ckanext/gobar_theme/public/user_images
WORKDIR /app-andino
RUN $CKAN_HOME/bin/pip install -e git+https://github.com/datosgobar/portal-andino-theme.git#egg=ckanext-gobar_theme
RUN mkdir -p $CKAN_DIST_MEDIA
RUN chown -R www-data:www-data $CKAN_DIST_MEDIA
RUN chmod u+rwx $CKAN_DIST_MEDIA
