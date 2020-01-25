# SecurityContext

## Crear pod que se ejecute como usuario 1000

  * Crear un pod basico que se ejecute como usuario 1000 (nombre: sleeper1, image: busybox, command: "sleep 3600")

## Interpretar configuracion

  * Dado el siguiente Pod

```
apiVersion: v1
kind: Pod
metadata:
  name: multi-pod
spec:
  securityContext:
    runAsUser: 1001
  containers:
  -  image: ubuntu
     name: web
     command: ["sleep", "5000"]
     securityContext:
      runAsUser: 1002
  -  image: ubuntu
     name: sidecar
     command: ["sleep", "5000"]
```

  * ¿Con que usuario se ejecuta el contenedor "web"?
  * ¿Con que usuario se ejecuta el contenedor "sidecar"?

## Capabilities

  * En el contenedor "sleeper1" del primer apartado, intentar cambiar la fecha con "date -s '28 DEC 2020 00:00:00'"

  * Editar el Pod para cambiar el usuario a root y añadir la capability SYS_TIME y volver a probar. Puede ser necesario borrar el Pod y volver a crearlo
