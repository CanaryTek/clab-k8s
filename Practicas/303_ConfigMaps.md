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

```
kubectl expose deployment webapp-color --port 80 --target-port 8080 --type LoadBalancer
```

  * Acceder a la IP del servicio
  * ¿Que color se muestra?

## Modificar configuracion mediante variable de entorno

  * La imagen webapp-color permite definir el color mediante la variable APP_COLOR
  * Redefinir el Deployment anterior para que muestre color rojo (APP_COLOR=red)
  * Pista: Añadir variable de entorno APP_COLOR=red como atributo del contenedor (ojo con la indentacion)

```
        env:
        - name: APP_COLOR
          value: red
```

## Crear configmap

  * Crear un ConfigMap app-config con APP_COLOR=blue

```
kubectl create configmap app-config --from-literal="APP_COLOR=blue"
```

  * Verificar

```
kubectl describe configmap app-config
```

  * Modificar el Deployment para que lea el entorno desde ese configMap
    * Pista: Editar la definicion del "env" para que se lea de configmap

```
        envFrom:
          - configMapRef:
              name: app-config
```

  * Recargar página. ¿A cambiado el color al del configmap?

## Editar configmap

  * Editar configmap (kubectl edit configmap) y definir APP_COLOR=pink
  * ¿Pasa algo?
  * Forzar un rollout para que use la nueva configuracion

```
kubectl rollout restart deployment webapp-color ; kubectl get pod -w
``` 

## Extra

  * Crear un Pod nginx que muestre una pagina con el nombre del grupo de practicas
  * Se debe leer la pagina desde un ConfigMap

  * Crear ConfigMap

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-data
data:
  index.html: "GRUPO 01"
```

  * Crear Pod

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx1
  name: nginx1
spec:
  containers:
  - image: nginx
    name: nginx1
    volumeMounts:
      - mountPath: /usr/share/nginx/html
        name: data-vol
  volumes:
    - name: data-vol
      configMap: 
        name: nginx-data
```

  * Crear Service

```
apiVersion: v1
kind: Service
metadata:
  labels:
    run: nginx1
  name: nginx1
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: nginx1
  type: LoadBalancer
```

