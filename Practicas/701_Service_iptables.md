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
linux@master01:~$ kubectl get svc nginx
NAME    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   10.111.248.8   <none>        80/TCP    32s
```

  * Localizamos entradas NAT con esa IP (sustituir la IP del ejemplo por la obtenida)

```
linux@master01:~$ sudo iptables -L -t nat -v | grep 10.111.248.8
    0     0 KUBE-MARK-MASQ  tcp  --  any    any    !10.32.0.0/12         10.111.248.8         /* default/nginx: cluster IP */ tcp dpt:http
    0     0 KUBE-SVC-4N57TFCL4MD7ZTDA  tcp  --  any    any     anywhere             10.111.248.8         /* default/nginx: cluster IP */ tcp dpt:http
```

  * Los númmeros 0 0 indican numero de paquetes y bytes que han hecho "match" de esa regla. Estan a cero porque el servicio acabamos de crearlo y no le ha llegado tráfico

  * Generamos una peticion

```
curl http://10.111.248.8
```

  * Volvemos a consultar iptables

```
linux@master01:~$ sudo iptables -L -t nat -v | grep 10.111.248.8
    1    60 KUBE-MARK-MASQ  tcp  --  any    any    !10.32.0.0/12         10.111.248.8         /* default/nginx: cluster IP */ tcp dpt:http
    1    60 KUBE-SVC-4N57TFCL4MD7ZTDA  tcp  --  any    any     anywhere             10.111.248.8         /* default/nginx: cluster IP */ tcp dpt:http
```

  * Como puede verse, ahora nos indica que 1 paquete y 60 bytes han hecho "match". Puede parecer extraño que solo indique 1 paquete, ya que al ser TCP sabemos que la peticion tienen que ser mas de 1 paquete. El "truco" es que se usa "connection tracking" y los paquetes pertenecientes a una conexion establecida (RELATED,ESTABLISHED) se tratan en otras cadenas

  * A partir de aqui, hacer seguimiento de las tablas de destino para determinar que Pod sirvió la peticion

  * Consultamos la tabla del servicio (KUBE-SVC-4N57TFCL4MD7ZTDA)

```
linux@master01:~$ sudo iptables -LKUBE-SVC-4N57TFCL4MD7ZTDA   -t nat -v 
Chain KUBE-SVC-4N57TFCL4MD7ZTDA (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 KUBE-SEP-WLLCSBA3BQWZPEAI  all  --  any    any     anywhere             anywhere             statistic mode random probability 0.25000000000
    0     0 KUBE-SEP-YNFGPHGQ6JTYNYZO  all  --  any    any     anywhere             anywhere             statistic mode random probability 0.33332999982
    1    60 KUBE-SEP-RNUA2WF32F4IZIFK  all  --  any    any     anywhere             anywhere             statistic mode random probability 0.50000000000
    0     0 KUBE-SEP-ZZWMMMZWIOYPPLV7  all  --  any    any     anywhere             anywhere            
```

  * Vemos que la peticion se ha enruta a la tabla KUBE-SEP-RNUA2WF32F4IZIFK. Veamos que "endpoint" se corresponde con esa tabla

```
linux@master01:~$ sudo iptables -L KUBE-SEP-RNUA2WF32F4IZIFK  -t nat -v 
Chain KUBE-SEP-RNUA2WF32F4IZIFK (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 KUBE-MARK-MASQ  all  --  any    any     10.44.0.1            anywhere            
    1    60 DNAT       tcp  --  any    any     anywhere             anywhere             tcp to:10.44.0.1:80
```

  * Vemos que la IP de destino a la que se hace DNAT es 10.44.0.1. Veamos a que pod corresponde esa IP

```
linux@master01:~$ kubectl get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
nginx-86c57db685-6z7mb   1/1     Running   0          22m   10.44.0.2   node01   <none>           <none>
nginx-86c57db685-jxrqm   1/1     Running   0          22m   10.36.0.2   node02   <none>           <none>
nginx-86c57db685-ttkzt   1/1     Running   0          22m   10.36.0.3   node02   <none>           <none>
nginx-86c57db685-vskrb   1/1     Running   0          22m   10.44.0.1   node01   <none>           <none>
```

  * Vemos que se corresponde con el ultimo Pod (nginx-86c57db685-vskrb). Por lo tanto, hemos podido seguir el trafico de la peticion, a traves de todas las cadenas iptables de NAT, hasta localizar que Pod es el que ha servido nuestra peticion

