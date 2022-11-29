# Network Policies

## Desplegar aplicacion basica

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
    image: mysql:5.7
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
    env:
      - name: DB_Host
        value: sql01
      - name: DB_User
        value: root
      - name: DB_Password
        value: password123
```

  * Conectarnos con el navegador a la IP del balanceador
  * ¿Funciona?

## Aplicar NetworkPolicy a mysql-pod

  * Aplicar la siguiente NetworkPolicy

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: mysql-policy
spec:
  podSelector:
    matchLabels:
      name: mysql
  policyTypes:
  - Ingress
  - Egress
  ingress: []
  egress: []
```

  * Volver a probar la conexion. ¿Funciona? ¿Por que? (OJO: puede ser necesario esperar un poco para ver el resultado)
  * Modificar las network policies de forma que la app vuelva a funcionar, pero este protegida (no vale permitir todo)
    * PISTA: Usar "kubectl describe netpol" para ver como se estan interpretando los selectores
    * PISTA: La solucion esta en el directorio "Respuestas", pero antes de mirarla intentalo!

## Aplicar NetworkPolicy a webapp-pod

  * Aplicar la siguiente NetworkPolicy

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: webapp-policy
spec:
  podSelector:
    matchLabels:
      name: webapp-pod
  policyTypes:
  - Ingress
  - Egress
  ingress: []
  egress: []
```

  * Volver a probar la conexion. ¿Funciona? ¿Por que? (OJO: puede ser necesario esperar un poco para ver el resultado)
  * Modificar las network policies de forma que la app vuelva a funcionar, pero este protegida (no vale permitir todo)
    * ¡OJO! La configuracion de conexion a la bbdd esta por nombre del servicio (sql01), asi que hay que permitir las consultas DNS en el Egress
    * PISTA: La solucion esta en el directorio "Respuestas", pero antes de mirarla intentalo!

