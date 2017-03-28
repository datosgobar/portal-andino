# Portal Andino

## Uso

Una vez finalizada la instalación, bajo cualquiera de los métodos, deberíamos:

### Crear usuario administrador
	
```bash		
# Agregar un admin
# Asumo que el contenedor de ckan es llamado "andino"
ADMIN_USER=<my_admin>        
docker exec -it andino /etc/ckan_init.d/add_admin.sh "$ADMIN_USER"
```

