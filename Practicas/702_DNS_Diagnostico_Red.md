# DNS y diagnostico avanzado de Red

En esta práctica utilizaremos técnicas de diagnóstico avanzado de redes para verificar el comportamiento del servicio DNS

Lo que haremos es ejecutar un contenedor con ubuntu en modo interactivo (muy util para tareas puntuales de diagnóstico), y capturaremos el tráfico DNS generado al hacer un ping a www.google.com

## Ejecutar contenedor para diagnóstico de red

  * Ejecutaremos un contenedor basado en ubuntu. En este caso usamos ubuntu en lugar de busybox, que es el que hemos usado en la mayoria de las prácticas anteriores, porque busybox no tiene en cuenta la opcion "ndots:5" en el resolv.conf

  * Ejecutamos el pod ubuntu en modo interactivo

```
linux@master01:~$ kubectl run -it test --rm --image=ubuntu --restart=Never --
```

  * El comando anterior ejecuta un Pod con ubuntu y nos deja en un shell interactivo. El Pod se elimina al salir del shell

  * Dentro de la shell, instalamos las utilidades necesarias para hacer un ping

```
root@test:/# apt-get -y update
root@test:/# apt-get -y install iputils-ping
```

## DNS en otros namespaces

  * Desplegar un pod y un servicio en un namespace diferente

```
kubectl create ns test
kubectl -n test run nginx --image nginx --generator run-pod/v1
kubectl -n test expose pod nginx --port 80
```

  * Verificamos que se este ejecutando

```
linux@master01:~$ kubectl -n test get pod -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          53s   10.46.0.6   node01   <none>           <none>
linux@master01:~$ kubectl -n test get svc
NAME    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   10.111.160.10   <none>        80/TCP    53s

```

  * Verificar que el servicio responde

```
linux@master01:~$ curl http://10.111.160.10
```

  * En el pod de test, trata de resolver el nombre del servicio y del pod. ¿Que nombre hay que usar en cada caso? ¿Puedes usar curl para conectarte por nombre, tanto al servicio como al Pod?

    * Al Servicio

```
curl http://nginx.test
curl http://nginx.test.svc
curl http://nginx.test.svc.cluster.local
```

    * Al Pod

```
curl http://10-44-0-3.test.pod
curl http://10-44-0-3.test.pod.cluster.local
```

## Capturar tráfico en el interfaz del contenedor de diagnostico

Vamos a capturar el tráfico desde **fuera del Pod** para aprender tecnicas de diagnóstico de red

  * Localizamos en qué nodo se esta ejecutando el Pod

```
linux@master01:~$ kubectl get pod test -o wide
NAME   READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
test   1/1     Running   0          13s   10.46.0.4   node01   <none>           <none>
```

  * En este caso, esta en el nodo "node01". Nos conectamos por SSH a dicho nodo

  * Vemos qué interfaces estan conectados al bridge weave (el de la solucion de red que estamos usando)

```
linux@node01:~$ brctl show
bridge name	bridge id		STP enabled	interfaces
docker0		8000.02424f5e1cbd	no		
weave		8000.72c80ca7a2a4	no		vethwe-bridge
							vethwepl3e728f6
							vethwepl4dd1bc0
							vethwepl4ecdd82
							vethwepla52510e
							vethweplb80dcf0
```

  * Nuestro Pod debe estar conectado a uno de esos interfaces veth*, pero ¿a cual?

  * Buscamos el contenedor docker

```
linux@node01:~$ sudo docker ps | grep test
32081a12c169        ubuntu                 "/bin/bash"              15 minutes ago      Up 15 minutes                           k8s_test_test_default_aa3f00f5-6534-4ac9-bc6f-ce84bedf6642_0
a52510ec6ab3        k8s.gcr.io/pause:3.1   "/pause"                 15 minutes ago      Up 15 minutes                           k8s_POD_test_default_aa3f00f5-6534-4ac9-bc6f-ce84bedf6642_0
```

  * Vemos que nuestro contenedor es el "32081a12c169", pero tambien nos aparece otro con imagen "k8s.gcr.io/pause:3.1" con id "a52510ec6ab3"
  * En el listado de interfaces del bridge, no vemos ninguno con el id de nuestro contenedor, pero si uno con el id del contenedor "pause" (vethwepla52510e)
  * El contenedor "pause" es un contenedor auxiliar que utiliza kubernetes para implementar la comparticion de espacios de nombres en Docker. Cada vez que se crea un Pod, kubernetes crea un contenedor Docker con la imagen "pause" y luego crea los demas contenedores del Pod, compartiendo los espacios de nombres del contenedor "pause"
  * Esto quiere decir, que nuestro contenedor 32081a12c169 comparte el mismo espacio de nombres que el a52510ec6ab3 y, por tanto, estan en el mismo interfaz vethwepla52510e
  * Para verificarlo, vamos a consultar la IP dentro del espacio de nombres de cada contenedor

  * Localizamos el Pid del contenedor Pause

```
linux@node01:~$ sudo docker inspect --format '{{.State.Pid}}' a52510ec6ab3
28871
```

  * Vemos la IP dentro del namespace de dicho PID

```
linux@node01:~$ sudo nsenter -t 28871 -n ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
67: eth0@if68: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue state UP group default 
    link/ether fa:2d:ae:87:ae:b8 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.46.0.4/12 brd 10.47.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

  * Localizamos el Pid del contenedor test

```
linux@node01:~$ sudo docker inspect --format '{{.State.Pid}}' 32081a12c169
28994
```

  * Vemos la IP dentro del namespace de dicho PID

```
linux@node01:~$ sudo nsenter -t 28994 -n ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
67: eth0@if68: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue state UP group default 
    link/ether fa:2d:ae:87:ae:b8 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.46.0.4/12 brd 10.47.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

  * Es decir, que en ambos casos obtenemos la misma IP, y lo que es mas importante, en ambos casos la eth0 esta vinculada al "if68"

  * Verificamos que la IP del pod test es esa

```
linux@master01:~$ kubectl get pod test -o wide
NAME   READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
test   1/1     Running   0          13s   10.46.0.4   node01   <none>           <none>
```

  * Efectivamente la IP de nuestro Pod es la que hemos visto en el contenedor

  * Tambien podemos verificar que el interfaz que tiene el id del contenedor pause es efectivamente el de dichos contenedores, fijandonos en el "@if68". El "@if68" indica que esa interfaz forma parte de un par "veth" conectado al interfaz con id "68". Si miramos las interfaces en el namespace principal del host:

```
linux@node01:~$ ip li | grep "68:"
68: vethwepla52510e@if67: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue master weave state UP mode DEFAULT group default 
```

  * Como podemos ver, el interfaz "68" es el vethwepla52510e, que es el que corresponde con el id de contenedor "pause". Y ademas nos dice que el otro extremos del par "veth" es el "if67", que es el que vimos dentro del espacio de nombres del contenedor "test" y "pause"

## Capturar trafico del contedor "test"

  * Una vez localizado el interfaz al que esta conectado el Pod test, podemos capturar trafico DNS en dicho interfaz

```
linux@node01:~$ sudo tshark -i vethwepla52510e port 53
Running as user "root" and group "root". This could be dangerous.
Capturing on 'vethwepla52510e'
```

  * Dejar la captura anterior en una pantalla abierta y abrir otra conexion

  * En el contenedor "test", hacemos ping (forzando el uso de IPv4), para forzar una resolucion DNS de www.google.com

```
root@test:/# ping -4 www.google.com
PING www.google.com (216.58.211.36) 56(84) bytes of data.
64 bytes from mad08s05-in-f4.1e100.net (216.58.211.36): icmp_seq=1 ttl=51 time=28.3 ms
64 bytes from mad08s05-in-f4.1e100.net (216.58.211.36): icmp_seq=2 ttl=51 time=28.0 ms
```

  * Y en la pantalla en la que estabamos capturando trafico, vemos los siguiente:

```
linux@node01:~$ sudo tshark -i vethwepla52510e port 53
Running as user "root" and group "root". This could be dangerous.
Capturing on 'vethwepla52510e'
    1 0.000000000    10.46.0.4 → 10.96.0.10   DNS 100 Standard query 0x7a59 A www.google.com.default.svc.cluster.local
    2 0.000943206   10.96.0.10 → 10.46.0.4    DNS 193 Standard query response 0x7a59 No such name A www.google.com.default.svc.cluster.local SOA ns.dns.cluster.local
    3 0.001265846    10.46.0.4 → 10.96.0.10   DNS 92 Standard query 0x4d16 A www.google.com.svc.cluster.local
    4 0.001376314    10.46.0.4 → 10.40.0.1    DNS 92 Standard query 0x4d16 A www.google.com.svc.cluster.local
    5 0.006106156   10.96.0.10 → 10.46.0.4    DNS 185 Standard query response 0x4d16 No such name A www.google.com.svc.cluster.local SOA ns.dns.cluster.local
    6 0.007924217    10.46.0.4 → 10.96.0.10   DNS 88 Standard query 0xfb6d A www.google.com.cluster.local
    7 0.009049346   10.96.0.10 → 10.46.0.4    DNS 181 Standard query response 0xfb6d No such name A www.google.com.cluster.local SOA ns.dns.cluster.local
    8 0.009399190    10.46.0.4 → 10.96.0.10   DNS 78 Standard query 0x6c17 A www.google.com.lan
    9 0.040176647   10.96.0.10 → 10.46.0.4    DNS 153 Standard query response 0x6c17 No such name A www.google.com.lan SOA a.root-servers.net
   10 0.040594700    10.46.0.4 → 10.96.0.10   DNS 74 Standard query 0xac22 A www.google.com
   11 0.070662515   10.96.0.10 → 10.46.0.4    DNS 104 Standard query response 0xac22 A www.google.com A 216.58.211.36
```

  * ¿Por que hace tantas consultas?
  * Si hacemos ping a "www.google.com." (con punto final) ¿tambien hace las consultas anteriores? ¿Por que?


