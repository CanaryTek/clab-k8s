# Services con iptables

En esta practica seguiremos el rastro al tráfico de red hacia un servicio

## Crear un Deployment con varios Pod nginx

  * Creamos el siguiente Deployment y Servicio

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    app: nginx
```

  * Identificamos la IP asignada al servicio

```
linux@master01:~$ kubectl get svc  nginx
NAME    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   10.110.108.56   <none>        80/TCP    79s
```

  * Localizamos entradas NAT con esa IP (sustituir la IP del ejemplo por la obtenida)

```
linux@master01:~$ sudo iptables -L -t nat -v | grep 10.110.108.56
    0     0 KUBE-MARK-MASQ  tcp  --  any    any    !10.32.0.0/12         10.110.108.56        /* default/nginx: cluster IP */ tcp dpt:http
    0     0 KUBE-SVC-4N57TFCL4MD7ZTDA  tcp  --  any    any     anywhere             10.110.108.56        /* default/nginx: cluster IP */ tcp dpt:http
```

  * Los númmeros 0 0 indican numero de paquetes y bytes que han hecho "match" de esa regla. Estan a cero porque el servicio acabamos de crearlo y no le ha llegado tráfico

  * Generamos una peticion

```
curl http://10.110.108.56
```

  * Volvemos a consultar iptables

```
linux@master01:~$ sudo iptables -L -t nat -v | grep 10.110.108.56
    1    60 KUBE-MARK-MASQ  tcp  --  any    any    !10.32.0.0/12         10.110.108.56        /* default/nginx: cluster IP */ tcp dpt:http
    1    60 KUBE-SVC-4N57TFCL4MD7ZTDA  tcp  --  any    any     anywhere             10.110.108.56        /* default/nginx: cluster IP */ tcp dpt:http
```

  * Como puede verse, ahora nos indica que 1 paquete y 60 bytes han hecho "match". Puede parecer extraño que solo indique 1 paquete, ya que al ser TCP sabemos que la peticion tienen que ser mas de 1 paquete. El "truco" es que se usa "connection tracking" y los paquetes pertenecientes a una conexion establecida (RELATED,ESTABLISHED) se tratan en otras cadenas

  * A partir de aqui, hacer seguimiento de las tablas de destino para determinar que Pod sirvió la peticion
