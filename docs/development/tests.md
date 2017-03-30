# Tests 

Para correr los test de la aplicación se deben levantar todos los servicios y luego inicializar la configuración de test.

### Tests de Ckan
    $ docker-compose -f dev.yml up --build -d andino
    $ docker exec andino bash /etc/ckan_init.d/tests/install_solr4.sh    
    $ docker exec andino bash -c 'su -c "bash /etc/ckan_init.d/tests/init_tests.sh; bash /etc/ckan_init.d/tests/run_tests.sh" -l $USER'
