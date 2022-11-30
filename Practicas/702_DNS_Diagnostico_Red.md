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
root@test:/# apt-get -y install iputils-ping curl
```

## DNS en otros namespaces

  * Desplegar un pod y un servicio en un namespace diferente

```
kubectl create ns test
kubectl -n test run nginx --image nginx
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

```bash
linux@master01:~$ kubectl get pod test -o wide
NAME   READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
test   1/1     Running   0          12m   10.32.0.6   node01   <none>           <none>
```

  * En este caso, esta en el nodo "node01". Nos conectamos por SSH a dicho nodo

  * Vemos los pods que tenemos en ejecucion y localizamos el que nos interesa

```bash
linux@node01:~$ sudo crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD
3e58b5111dc5a       9d5226e6ce3fb       6 minutes ago       Running             busybox-sleeper     3                   3a0caba05c76a       busybox-sleeper
2cc51962e6c7a       a8780b506fa4e       30 minutes ago      Running             test                0                   d0947c91d28a5       test
b7c97a994ada2       88736fe827391       45 minutes ago      Running             nginx               0                   17283931078bd       nginx-85b98978db-g48tl
7a769f0302b41       88736fe827391       45 minutes ago      Running             nginx               0                   c39a05162a2af       nginx-85b98978db-zn797
5f3e7b5178ea9       88736fe827391       49 minutes ago      Running             nginx               0                   abd8544e405db       local-pv-user-0
10a49f84aa25c       690c3345cc9c3       About an hour ago   Running             weave-npc           1                   4be0e3b3d72f5       weave-net-68tsb
0bace2b40961d       62fea85d60522       About an hour ago   Running             weave               2                   4be0e3b3d72f5       weave-net-68tsb
e8ee0ccb36984       655281c411871       About an hour ago   Running             kube-proxy          1                   df01c6838714e       kube-proxy-56p8x
```

  * En nuestro caso es el segundo (POD ID d0947c91d28a5)
  * Buscamos un interfaz de red con los primeros numeros del POD ID:

```bash
linux@node01:~$ sudo ip a | grep d0947c
19: vethwepld0947c9@if18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue master weave state UP group default 
```

  * El interfaz conectado a ese pod es el vethwepld0947c9, obtenemos los detalles

```bash
linux@node01:~$ sudo ip a l dev vethwepld0947c9
19: vethwepld0947c9@if18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue master weave state UP group default 
    link/ether a6:83:b9:0b:81:5d brd ff:ff:ff:ff:ff:ff link-netns cni-dc049986-08e0-6f1a-ae1c-b0a10bc3e576
    inet6 fe80::a483:b9ff:fe0b:815d/64 scope link 
       valid_lft forever preferred_lft forever
```

  * Vemos que el namespace es el cni-dc049986-08e0-6f1a-ae1c-b0a10bc3e576
  * Podemos "entrar" en ese namespace y verificar que la IP es la del contenedor

```bash
linux@node01:~$ sudo ip netns exec cni-dc049986-08e0-6f1a-ae1c-b0a10bc3e576 bash
root@node01:/home/linux# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
18: eth0@if19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue state UP group default 
    link/ether 3a:72:2c:8c:36:ba brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.32.0.6/12 brd 10.47.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::3872:2cff:fe8c:36ba/64 scope link 
       valid_lft forever preferred_lft forever
root@node01:/home/linux# exit
exit
```

  * Efectivamente la IP de nuestro Pod es la que hemos visto en el contenedor

  * Tambien podemos fijarnos en el "@if19". El "@if19" indica que esa interfaz forma parte de un par "veth" conectado al interfaz con id "19". Si miramos las interfaces en el namespace principal del host:

```
linux@node01:~$ ip li | grep "^19:"
19: vethwepld0947c9@if18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue master weave state UP mode DEFAULT group default 
```

  * Como podemos ver, el interfaz "19" es el vethwepld0947c9, y ademas nos dice que el otro extremo del par "veth" es el "if18", que es el que vimos dentro del espacio de nombres del pod "test"

## Capturar trafico del contedor "test"

  * Una vez localizado el interfaz al que esta conectado el Pod test, podemos capturar trafico DNS en dicho interfaz

```
linux@node01:~$ sudo tshark -i vethwepld0947c9 port 53
Running as user "root" and group "root". This could be dangerous.
Capturing on 'vethwepld0947c9'
```

  * Dejar la captura anterior en una pantalla abierta y abrir otra conexion

  * En el contenedor "test", hacemos ping (forzando el uso de IPv4), para forzar una resolucion DNS de www.google.com

```bash
root@test:/# ping -4 www.google.com
PING www.google.com (216.58.211.36) 56(84) bytes of data.
64 bytes from mad08s05-in-f4.1e100.net (216.58.211.36): icmp_seq=1 ttl=51 time=28.3 ms
64 bytes from mad08s05-in-f4.1e100.net (216.58.211.36): icmp_seq=2 ttl=51 time=28.0 ms
```

  * Y en la pantalla en la que estabamos capturando trafico, vemos los siguiente:

```bash
Running as user "root" and group "root". This could be dangerous.
Capturing on 'vethwepld0947c9'
    1 0.000000000    10.32.0.6 → 10.96.0.10   DNS 100 Standard query 0xf78f A www.google.com.default.svc.cluster.local
    2 0.000092685    10.32.0.6 → 10.38.0.2    DNS 100 Standard query 0xf78f A www.google.com.default.svc.cluster.local
    3 0.000206936    10.32.0.6 → 10.96.0.10   DNS 100 Standard query 0xd98a AAAA www.google.com.default.svc.cluster.local
    4 0.000219534    10.32.0.6 → 10.38.0.2    DNS 100 Standard query 0xd98a AAAA www.google.com.default.svc.cluster.local
    5 0.000897891   10.96.0.10 → 10.32.0.6    DNS 193 Standard query response 0xd98a No such name AAAA www.google.com.default.svc.cluster.local SOA ns.dns.cluster.local
    6 0.000983311   10.96.0.10 → 10.32.0.6    DNS 193 Standard query response 0xf78f No such name A www.google.com.default.svc.cluster.local SOA ns.dns.cluster.local
    7 0.001074149    10.32.0.6 → 10.96.0.10   DNS 92 Standard query 0x8795 A www.google.com.svc.cluster.local
    8 0.001203855    10.32.0.6 → 10.96.0.10   DNS 92 Standard query 0xa488 AAAA www.google.com.svc.cluster.local
    9 0.001519984   10.96.0.10 → 10.32.0.6    DNS 185 Standard query response 0xa488 No such name AAAA www.google.com.svc.cluster.local SOA ns.dns.cluster.local
   10 0.001617194   10.96.0.10 → 10.32.0.6    DNS 185 Standard query response 0x8795 No such name A www.google.com.svc.cluster.local SOA ns.dns.cluster.local
   11 0.001668154    10.32.0.6 → 10.96.0.10   DNS 88 Standard query 0x41c8 A www.google.com.cluster.local
   12 0.001688107    10.32.0.6 → 10.38.0.1    DNS 88 Standard query 0x41c8 A www.google.com.cluster.local
   13 0.001770775    10.32.0.6 → 10.96.0.10   DNS 88 Standard query 0x32ce AAAA www.google.com.cluster.local
   14 0.001780406    10.32.0.6 → 10.38.0.1    DNS 88 Standard query 0x32ce AAAA www.google.com.cluster.local
   15 0.002124305   10.96.0.10 → 10.32.0.6    DNS 181 Standard query response 0x32ce No such name AAAA www.google.com.cluster.local SOA ns.dns.cluster.local
   16 0.002211842   10.96.0.10 → 10.32.0.6    DNS 181 Standard query response 0x41c8 No such name A www.google.com.cluster.local SOA ns.dns.cluster.local
   17 0.002309731    10.32.0.6 → 10.96.0.10   DNS 74 Standard query 0xb4c4 A www.google.com
   18 0.002380614    10.32.0.6 → 10.96.0.10   DNS 74 Standard query 0xb7c6 AAAA www.google.com
   19 0.046642069   10.96.0.10 → 10.32.0.6    DNS 116 Standard query response 0xb7c6 AAAA www.google.com AAAA 2a00:1450:4003:806::2004
   20 0.047371826   10.96.0.10 → 10.32.0.6    DNS 104 Standard query response 0xb4c4 A www.google.com A 142.250.185.4
```

  * ¿Por que hace tantas consultas?
  * Si hacemos ping a "www.google.com." (con punto final) ¿tambien hace las consultas anteriores? ¿Por que?


