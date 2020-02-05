# Secrets

## Configurar env desde Secret

  * Crear los siguientes objetos

```
apiVersion: v1
kind: Service
metadata:
  name: sql01
spec:
  ports:
  - port: 3306
    protocol: TCP
    targetPort: 3306
  selector:
    name: mysql
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    name: webapp-pod
  type: LoadBalancer
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: mysql
  name: mysql
spec:
  containers:
  - env:
    - name: MYSQL_ROOT_PASSWORD
      value: password123
    image: mysql
    imagePullPolicy: Always
    name: mysql
    ports:
    - containerPort: 3306
      protocol: TCP
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: webapp-pod
  name: webapp-pod
spec:
  containers:
  - image: kodekloud/simple-webapp-mysql
    name: webapp
```

  * Conectarse con el navegador a la IP del servicio webapp-service
  * Debe aparecer una pagina de error, porque la app no esta configurada

  * Crear un Secret para almacenar los siguientes datos

```
DB_Host=sql01
DB_User=root
DB_Password=password123
```

  * Pista: algo asi...

```
kubectl create secret generic db-secret --from-literal="key1=value" --from-literal="key2=value2"
```

  * Modificar el Pod "webapp-pod" para usar el Secret anterior como variables de entorno
    * Puede ser necesario eliminar el Pod para volver a crearlo

  * Pista: algo asi...

```
    envFrom:
      - secretRef:
          name: db-secret
```

  * Volver a conectarse al navegador y verificar que funciona 

