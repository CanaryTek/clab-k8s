# Multicontainer Pods

## Crear Pod con 2 containers

  * Crear un Pod (Nombre: multi) con los  siguientes contenedores
    * Nombre: nginx, image: nginx
    * Nombre: log, image: busybox, command: "sleep 10"

```
apiVersion: v1
kind: Pod
metadata:
  name: multi
spec:
  containers:
  - image: nginx
    name: nginx
  - image: busybox
    name: busybox
    command:
    - "sleep"
    - "10"
```

  * Comprobar que en la columna READY de "kubectl get pod" aparecen los 2 ejecutandose

  * Esperar un rato. ¿Que pasa?

