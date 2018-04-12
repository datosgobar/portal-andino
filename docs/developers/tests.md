# Tests

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Tests de Ckan](#tests-de-ckan)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Para correr los test de la aplicación, se deben levantar todos los servicios y luego inicializar la configuración de test.

### Tests de Ckan
    $ docker-compose -f dev.yml up --build -d portal
    $ docker exec andino bash /etc/ckan_init.d/tests/install_solr4.sh    
    $ docker exec andino bash /etc/ckan_init.d/tests/install_nodejs.sh    
    $ docker exec andino bash -c 'su -c "bash /etc/ckan_init.d/tests/run_all_tests.sh" -l $USER'
