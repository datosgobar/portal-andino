# Instalación con Docker (WIP)

### Esta guía instala la última version _en desarrollo_ de andino, puede contener bugs o no funcionar

Esta clase de instalación no requiere que clones el repositorio, ya que usamos contenedores alojados en [DockerHub](https://hub.docker.com/r/datosgobar)

### Ubuntu 14.04

+ Requerimientos:
    - Docker: `sudo su -c "curl -sSL http://get.docker.com | sh"`
    - Docker compose: `https://docs.docker.com/compose/install/`

+ Instalación:

  Install script:

      sudo su -c "curl -sSL https://raw.github.com/datosgobar/portal-andino/development/deploy/install.sh | sh"
  
+ Inicialización:

        docker exec andino /etc/ckan_init.d/make_conf.sh
  
+ Customización

    - Crear un usuario administrador (Cambiar `ckan_admin` por otro usuario si se desea):
    
            docker exec -it andino /etc/ckan_init.d/add_admin.sh ckan_admin

    - Cambiar la url del sitio (Cambiar `dev.example.com` por el correspondiente dominio):
    
            docker exec -it andino /etc/ckan_init.d/change_site_url.sh http://dev.example.com
            
    - Cambiar la url por por la correcta (TBD: cual es la correcta?)
    
            docker exec -it andino /etc/ckan_init.d/change_datapusher_url.sh http://harvest.example.com:8800
