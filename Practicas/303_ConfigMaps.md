# ConfigMaps

## Crear un Deployment

  * Crear el siguiente Deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: webapp-color
  name: webapp-color
spec:
  replicas: 2
  selector:
    matchLabels:
      run: webapp-color
  template:
    metadata:
      labels:
        run: webapp-color
    spec:
      containers:
      - image: kukoarmas/webapp-color
        name: webapp-color
```

  * Crear servicio tipo "LoadBalancer" para acceder desde fuera
  * Acceder a la IP del servicio
  * ¿Que color se muestra?

## Modificar configuracion mediante variable de entorno

  * La imagen webapp-color permite definir el color mediante la variable APP_COLOR
  * Redefinir el Deployment anterior para que muestre color rojo (APP_COLOR=red)

## Crear configmap

  * Crear un ConfigMap app-config con APP_COLOR=green
  * Modificar el Deployment para que lea el entorno desde ese configMap

## Editar configmap

  * Editar configmap (kubectl edit configmap) y definir APP_COLOR=pink
  * ¿Pasa algo?
  * Forzar un rollout para que use la nueva configuracion

```
kubectl rollout restart deployment webapp-color ; kubectl get pod -w
``` 

