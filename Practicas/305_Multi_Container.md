# Multicontainer Pods

## Crear Pod con 2 containers

  * Crear un Pod (Nombre: multi) con los  siguientes contenedores
    * Nombre: nginx, image: nginx
    * Nombre: log, image: busybox, command: "sleep 10"

  * Comprobar que en la columna READY de "kubectl get pod" aparecen los 2 ejecutandose

  * Esperar un rato. ¿Que pasa?
