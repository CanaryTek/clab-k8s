# Ingress

En esta práctica instalaremos un Ingress Controller basado en Nginx y crearemos reglas Ingress para acceder a varias aplicaciones

## Instalar Ingress Controller

  * Desplegamos la version 1.0.4 del nginx ingress controller (OJO! para versiones de kubernetes 1.22 y superiores)

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.4/deploy/static/provider/cloud/deploy.yaml
```

  * Miramos la IP del servicio y nos conectamos con navegador

```
kubectl -n ingress-nginx get svc ingress-nginx
```

## Desplegar apps y servicios

  * Desplegamos 2 apps con sus correspondientes servicios

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: green
  name: green
spec:
  replicas: 2
  selector:
    matchLabels:
      run: green
  template:
    metadata:
      labels:
        run: green
    spec:
      containers:
      - image: kukoarmas/webapp-color
        name: green
        env:
          - name: APP_COLOR
            value: green
---
apiVersion: v1
kind: Service
metadata:
  labels:
    run: green
  name: green
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    run: green
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: blue
  name: blue
spec:
  replicas: 2
  selector:
    matchLabels:
      run: blue
  template:
    metadata:
      labels:
        run: blue
    spec:
      containers:
      - image: kukoarmas/webapp-color
        name: blue
        env:
          - name: APP_COLOR
            value: blue
---
apiVersion: v1
kind: Service
metadata:
  labels:
    run: blue
  name: blue
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    run: blue
  type: ClusterIP
```

  * Comprobar las IP de los servicios y verificar que responden a: curl http://IP_SERVICIO

## Configurar Ingress por URL

  * Configura las reglas Ingress necesarias para acceder a las apps a traves de las siguientes URL:
    * http://IP_SERVICIO_ingress_nginx/green -> app green
    * http://IP_SERVICIO_ingress_nginx/blue -> app blue

  * Usa el siguiente modelo (hay que adaptarlo)

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  name: my-ingress
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /url(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: url-service
            port:
              number: 80
```

<details>
 <summary>Pista</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  name: ingress-path
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /blue(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: blue
            port:
              number: 80
      - path: /green(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: green
            port:
              number: 80
```
 
</details>

## Configurar Ingress por host

  * Configura las reglas Ingress necesarias para acceder a las apps a traves de los siguientes Host:
    * http://green.myapp.local -> app green
    * http://blue.myapp.local -> app blue

  * Usar lo siguiente como modelo

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  name: my-ingress-host
spec:
  ingressClassName: nginx
  rules:
  - host: host.myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: host-svc
            port: 
              number: 80
```

**NOTA:** Como no disponemos de DNS, hay que apuntar esos nombres a la IP del servicio ingress-nginx en el fichero hosts de la maquina del alumno. Tambien puede probarse forzando la cabecera Host con curl: curl -H "Host: green.myapp.local" http://IP_SERVICIO_ingress_nginx

<details>
 <summary>Pista</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  name: ingress-host
spec:
  ingressClassName: nginx
  rules:
  - host: blue.myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: blue
            port:
              number: 80
  - host: green.myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: green
            port:
              number: 80
```

</details>

## Significado de externalTrafficPolicy en el Service

En esta practica veremos el significado de TrafficPolicy en el servicio nginx_service

  * Ver los logs del Pod nginx-ingress-controller

```
kubectl -n ingress-nginx logs -f nginx-ingress-controller-5556bd798f-lcrpw
```

  * Veremos el log de conexiones al nginx. Por ejemplo algo asi:

```
10.40.0.0 - - [29/Jan/2020:11:15:42 +0000] "GET / HTTP/1.1" 200 252 "-" "curl/7.58.0" 81 0.003 [default-green-80] [] 10.46.0.2:8080 252 0.000 200 4cd5e1dba488a210c7ef3c77f4aeb25d
10.40.0.0 - - [29/Jan/2020:11:15:43 +0000] "GET / HTTP/1.1" 200 252 "-" "curl/7.58.0" 81 0.008 [default-green-80] [] 10.46.0.2:8080 252 0.008 200 ce0b796965fa8090235bc909c194b052
10.40.0.0 - - [29/Jan/2020:11:15:49 +0000] "GET / HTTP/1.1" 200 251 "-" "curl/7.58.0" 80 0.006 [default-blue-80] [] 10.32.0.6:8080 251 0.008 200 fdd8f2ea54987a32edef13cc3b6cdcc5
10.40.0.0 - - [29/Jan/2020:11:15:51 +0000] "GET / HTTP/1.1" 200 252 "-" "curl/7.58.0" 81 0.009 [default-green-80] [] 10.32.0.2:8080 252 0.008 200 5dfad0800bd4a3a1ba35e8f79f6afbfc
```

  * Vemos que la IP de origen es una privada del cluster. Concretamente, la IP de weave del nodo donde se esta ejecutado el pod nginx-ingress-controller
  * ¿Que pasa si necesitamos saber la IP real del cliente (algo muy habitual en control de acceso)?

  * La razon por la que vemos la IP del cluster es que por defecto tenemos configurado externalTrafficPolicy=Cluster en el servicio nginx_ingress

  * El parametro esternalTrafficPolicy puede tener los siguientes valores:
    * **Cluster:** Con este valor, las peticiones externas se "reparten" entre todos los pods del cluster que dan ese servicio (endpoints). Para poder hacer esto, es necesario "enmascarar" la IP de origen con la del nodo por el que esta entrando el tráfico. Este modo es el que se usa por defecto porque es el necesario para "balancear" la carga entre pods en diferentes nodos, pero tiene el inconveniente de "ocultar" la IP de origen real
    * **Local:** Con este valor, se mantiene la IP de origen real de la petición, pero debido a eso, solo se puede enviar la peticion a Pods que se esten ejecutando en el mismo nodo por donde esta entrando el tráfico. Por eso este modo no es ideal cuando necesitamos balancear carga

  * Editamos el servicio y cambiar este parametro a Local

  * ¡OJO! El CNI de weave-net con la configuracion por defecto tiene esta funcionalidad desactivara. Para activarla hay que cambiar el despliegue añadiendo una opcion (se puede hacer en caliente)

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.NO_MASQ_LOCAL=1"
```

  * Volver a mirar los logs del ingress_nginx y verificar que ahora las IP de origen son las reales
