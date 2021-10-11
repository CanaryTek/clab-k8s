# Introduccion a Docker


## Comandos basicos


  * Consultar versión de docker

```bash
root@master01:~# docker version
Client:
 Version:           20.10.7
 API version:       1.41
 Go version:        go1.13.8
 Git commit:        20.10.7-0ubuntu1~18.04.2
 Built:             Fri Oct  1 21:47:31 2021
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server:
 Engine:
  Version:          20.10.7
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.13.8
  Git commit:       20.10.7-0ubuntu1~18.04.2
  Built:            Fri Oct  1 13:28:27 2021
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.5.2-0ubuntu1~18.04.3
  GitCommit:        
 runc:
  Version:          1.0.0~rc95-0ubuntu1~18.04.2
  GitCommit:        
 docker-init:
  Version:          0.19.0
  GitCommit:        
```

  * Ejecutar un contenedor básico

```bash
root@master01:~# docker run alpine
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
a0d0a0d46f8b: Pull complete 
Digest: sha256:e1c082e3d3c45cccac829840a25941e679c25d438cc8412c2fa221cf1a824e6a
Status: Downloaded newer image for alpine:latest
root@master01:~# 
```

  * ¿No ha hecho nada? Si, en realidad ha ejecutado y terminado porque no le hemos dicho qué debía ejecutar dentro del contenedor

  * Ejecutar un comando dentro del contenedor

```bash
root@master01:~# docker run alpine echo "Hola mundo"
Hola mundo
root@master01:~# 
```

  * Listar contenedores en ejecucion

```bash
root@master01:~# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
root@master01:~#
```

  * No muestra nada porque no tenemos ninguno ejecutandose (los anteriores ya han terminado=)

  * Listar todos los contenedores, incluídos los que estan parados

```bash
root@master01:~# docker ps -a
CONTAINER ID   IMAGE     COMMAND               CREATED         STATUS                     PORTS     NAMES
699d067f1142   alpine    "echo 'Hola mundo'"   2 minutes ago   Exited (0) 2 minutes ago             brave_cannon
0d1be1d6ea34   alpine    "/bin/sh"             3 minutes ago   Exited (0) 3 minutes ago             goofy_germain
```

  * Borrar contenedor (parado)

```bash
root@master01:~# docker rm 699d067f1142
699d067f1142
root@master01:~# docker ps -a
CONTAINER ID   IMAGE     COMMAND     CREATED         STATUS                     PORTS     NAMES
0d1be1d6ea34   alpine    "/bin/sh"   3 minutes ago   Exited (0) 3 minutes ago             goofy_germain
root@master01:~# 
```

  * Ejecutar un shell en modo interactivo

```bash
root@master01:~# docker run -ti --rm ubuntu bash -l
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
f3ef4ff62e0d: Pull complete 
Digest: sha256:a0d9e826ab87bd665cfc640598a871b748b4b70a01a4f3d174d4fb02adad07a9
Status: Downloaded newer image for ubuntu:latest
root@d233aac058e6:/# cat /etc/lsb-release 
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=20.04
DISTRIB_CODENAME=focal
DISTRIB_DESCRIPTION="Ubuntu 20.04.3 LTS"
root@d233aac058e6:/# logout
root@master01:~# 
```

  * Ha descargado la "imagen" con etiqueta "latest", que actualmente es la version 20.04.3 LTS de Ubuntu
  * La opcion "-ti" indica que queremos conectar la entrada estandar y el terminal, al contenedor (es una sesion interactiva)
  * La opcion "--rm" indica que el contenedor se borre automaticamente cuando termine
  * "bash -l" indica que queremos ejecutar un shell en "modo login"


  * Especificar la version de la imagen a ejecutar (tag)

```bash
root@master01:~# docker run -ti --rm ubuntu:16.04 bash -l
Unable to find image 'ubuntu:16.04' locally
16.04: Pulling from library/ubuntu
58690f9b18fc: Pull complete 
b51569e7c507: Pull complete 
da8ef40b9eca: Pull complete 
fb15d46c38dc: Pull complete 
Digest: sha256:454054f5bbd571b088db25b662099c6c7b3f0cb78536a2077d54adc48f00cd68
Status: Downloaded newer image for ubuntu:16.04
root@ca433d014c9d:/# cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.7 LTS"
```

  * Al indicar la etiqueta 16.04 en la imagen, hemos especificado qué version de esa imagen queremos ejecutar. Y ha ejecutado la version 16.04.7 de Ubuntu

  * Para ver el efecto de la opcion "--rm", listamos los contenedores

```bash
root@master01:~# docker ps -a
CONTAINER ID   IMAGE     COMMAND     CREATED          STATUS                      PORTS     NAMES
0d1be1d6ea34   alpine    "/bin/sh"   15 minutes ago   Exited (0) 15 minutes ago             goofy_germain
```

  * Como puede observarse, no ha quedado rastro de los contenedores ubuntu que ejecutamos con la opcion "--rm", porque se eliminaron al terminar el contenedor

  * Parada de contenedores en ejecucion

```bash
root@master01:~# docker run -d --name webserver nginx 
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
07aded7c29c6: Pull complete 
bbe0b7acc89c: Pull complete 
44ac32b0bba8: Pull complete 
91d6e3e593db: Pull complete 
8700267f2376: Pull complete 
4ce73aa6e9b0: Pull complete 
Digest: sha256:06e4235e95299b1d6d595c5ef4c41a9b12641f6683136c18394b858967cd1506
Status: Downloaded newer image for nginx:latest
a8302bea7f275b193a28d7fa7cdd80ff152371c4054b70b51a3f642af31df2c8
root@master01:~# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS     NAMES
a8302bea7f27   nginx     "/docker-entrypoint.…"   4 seconds ago   Up 2 seconds   80/tcp    webserver
root@master01:~# docker stop webserver
webserver
root@master01:~# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
root@master01:~# docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                      PORTS     NAMES
a8302bea7f27   nginx     "/docker-entrypoint.…"   17 seconds ago   Exited (0) 4 seconds ago              webserver
0d1be1d6ea34   alpine    "/bin/sh"                19 minutes ago   Exited (0) 19 minutes ago             goofy_germain
```

  * En el comando anterior, hemos ejecutado un contenedor nginx en segundo plano (-d), indicando que se ejecute con el nombre "webserver" (--name webserver)
    * A continuacion hemos listado los contenedores y ejecutvamente nuestro "webserver" estaba en ejecucion
    * Lo hemos parado con "docker stop"
    * Hemos verificado que ya no aparece en los contenedores en ejecucion

  * Podemos volver a arrancar un contenedor parado:

```bash
root@master01:~# docker start webserver
webserver
root@master01:~# docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                      PORTS     NAMES
a8302bea7f27   nginx     "/docker-entrypoint.…"   3 minutes ago    Up 2 seconds                80/tcp    webserver
0d1be1d6ea34   alpine    "/bin/sh"                22 minutes ago   Exited (0) 22 minutes ago             goofy_germain
root@master01:~# docker stop webserver
webserver
```

  * Listar imagenes

```bash
root@master01:~# docker images
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       latest    597ce1600cf4   8 days ago    72.8MB
nginx        latest    f8f4ffc8092c   11 days ago   133MB
ubuntu       16.04     b6f507652425   5 weeks ago   135MB
alpine       latest    14119a10abf4   6 weeks ago   5.6MB
```

  * Tags
    * Latest si no se especifica
    * En dockerhub se suelen listar los tags soportados


  * Eliminar imagenes (No podemos tener contenedores que la usen)

```bash
root@master01:~# docker images
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       latest    597ce1600cf4   8 days ago    72.8MB
nginx        latest    f8f4ffc8092c   11 days ago   133MB
ubuntu       16.04     b6f507652425   5 weeks ago   135MB
alpine       latest    14119a10abf4   6 weeks ago   5.6MB
root@master01:~# docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                      PORTS     NAMES
a8302bea7f27   nginx     "/docker-entrypoint.…"   6 minutes ago    Exited (0) 3 minutes ago              webserver
0d1be1d6ea34   alpine    "/bin/sh"                25 minutes ago   Exited (0) 25 minutes ago             goofy_germain
root@master01:~# docker rmi ubuntu nginx ubuntu:16.04 alpine
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:a0d9e826ab87bd665cfc640598a871b748b4b70a01a4f3d174d4fb02adad07a9
Deleted: sha256:597ce1600cf4ac5f449b66e75e840657bb53864434d6bd82f00b172544c32ee2
Deleted: sha256:da55b45d310bb8096103c29ff01038a6d6af74e14e3b67d1cd488c3ab03f5f0d
Untagged: ubuntu:16.04
Untagged: ubuntu@sha256:454054f5bbd571b088db25b662099c6c7b3f0cb78536a2077d54adc48f00cd68
Deleted: sha256:b6f50765242581c887ff1acc2511fa2d885c52d8fb3ac8c4bba131fd86567f2e
Deleted: sha256:0214f4b057d78b44fd12702828152f67c0ce115f9346acc63acdf997cab7e7c8
Deleted: sha256:1b9d0485372c5562fa614d5b35766f6c442539bcee9825a6e90d1158c3299a61
Deleted: sha256:3c0f34be6eb98057c607b9080237cce0be0b86f52d51ba620dc018a3d421baea
Deleted: sha256:be96a3f634de79f523f07c7e4e0216c28af45eb5776e7a6238a2392f71e01069
Error response from daemon: conflict: unable to remove repository reference "nginx" (must force) - container a8302bea7f27 is using its referenced image f8f4ffc8092c
Error response from daemon: conflict: unable to remove repository reference "alpine" (must force) - container 0d1be1d6ea34 is using its referenced image 14119a10abf4
```

  * No podemos borrar las imagenes nginx ni alpine porque tenemos contenedores que las usan (aunque esten parados)

  * Forzamos el borrado (tambien podriamos borrar los contenedores y luego las imagenes)

```bash
root@master01:~# docker rmi --force nginx alpine
Untagged: nginx:latest
Untagged: nginx@sha256:06e4235e95299b1d6d595c5ef4c41a9b12641f6683136c18394b858967cd1506
Deleted: sha256:f8f4ffc8092c956ddd6a3a64814f36882798065799b8aedeebedf2855af3395b
Untagged: alpine:latest
Untagged: alpine@sha256:e1c082e3d3c45cccac829840a25941e679c25d438cc8412c2fa221cf1a824e6a
Deleted: sha256:14119a10abf4669e8cdbdff324a9f9605d99697215a0d21c360fe8dfa8471bab
```

  * Podemos descargar una imagen sin ejecutarla

```bash
root@master01:~# docker pull ubuntu:18.04
18.04: Pulling from library/ubuntu
284055322776: Pull complete 
Digest: sha256:bfb4cabd667790ead5c95d9fe341937f0c21118fa79bc768d51c5da9d1dbe917
Status: Downloaded newer image for ubuntu:18.04
docker.io/library/ubuntu:18.04
```

## Comandos sobre contenedores en ejecucion

  * Ejecutamos un servidor web nginx en segundo plano

```bash
root@master01:~# docker run -d --name webserver nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
07aded7c29c6: Pull complete 
bbe0b7acc89c: Pull complete 
44ac32b0bba8: Pull complete 
91d6e3e593db: Pull complete 
8700267f2376: Pull complete 
4ce73aa6e9b0: Pull complete 
Digest: sha256:06e4235e95299b1d6d595c5ef4c41a9b12641f6683136c18394b858967cd1506
Status: Downloaded newer image for nginx:latest
a40912759484783d99bbc28cb928bd01b0e800030528b7c4de6bf8703bb7ecf0
```

  * Podemos consultar los logs del contenedor

```bash
root@master01:~# docker logs webserver
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2021/10/10 00:19:05 [notice] 1#1: using the "epoll" event method
2021/10/10 00:19:05 [notice] 1#1: nginx/1.21.3
2021/10/10 00:19:05 [notice] 1#1: built by gcc 8.3.0 (Debian 8.3.0-6) 
2021/10/10 00:19:05 [notice] 1#1: OS: Linux 4.15.0-70-generic
2021/10/10 00:19:05 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2021/10/10 00:19:05 [notice] 1#1: start worker processes
2021/10/10 00:19:05 [notice] 1#1: start worker process 33
2021/10/10 00:19:05 [notice] 1#1: start worker process 34
```

  * Una opcion muy util en los logs es la opcion "-f" que permanece conectado y sigue mostrando logs a medida que se producen (similar al "tail -f")

  * Tambien podemos conectarnos al proceso principal del contenedor

```bash
root@master01:~# docker attach webserver
172.17.0.1 - - [10/Oct/2021:00:28:25 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.58.0" "-"
```

  * En este caso, el terminal se nos queda conectado a la salida estandar el servidor web, por lo que nos mostraria el log de las conexiones al servidor web que se vayan produciendo. 
    * IMPORTANTE: Tras el attach, no se muestra nada. La entrada de log que se muestra la he forzado realizando una conecion con curl

  * OJO! Si se pulsa CTRl-C en el terminal del attach anterior, se parara el proceso nginx y, por tanto, el contenedor. Para arrancarlo puede hacerse mediante "docker start webserver"

  * Ejecutar un comando dentro de un contenedor en ejecucion

```bash
root@master01:~# docker exec -ti webserver bash -l
root@a40912759484:/# ps
bash: ps: command not found
root@a40912759484:/# cat /proc/1/cmdline
nginx: master process nginx -g daemon off;root@a40912759484:/# 
```

  * Ejecutamos un shell en el contenedor del webserver nginx
    * Al ser un contenedor minimo, no tenemos la utilidad "ps" para ver los procesos en ejecucion
    * Consultamos la linea de ejecucion del proceso 1 (cat /proc/1/cmdline) y vemos que efectivamente es el nginx (en un sistema linux completo deberia ser el proceso init)

  * Podemos consultar informacion sobre el contenedor

```bash
root@master01:~# docker inspect webserver
[
    {
        "Id": "a40912759484783d99bbc28cb928bd01b0e800030528b7c4de6bf8703bb7ecf0",
        "Created": "2021-10-10T00:19:05.059429474Z",
        "Path": "/docker-entrypoint.sh",
        "Args": [
            "nginx",
            "-g",
            "daemon off;"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 17209,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2021-10-10T00:36:01.902136291Z",
            "FinishedAt": "2021-10-10T00:35:59.622665205Z"
        },
[INFORMACION RECORTADA]
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "ecbc8cc0601bbaca548d6b9825cec5deba6ddbbf9f0e05df72b25803abd14eb7",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {
                "80/tcp": null
            },
            "SandboxKey": "/var/run/docker/netns/ecbc8cc0601b",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "de4e258fe781328a408fab2ec37eb4e1864c5f7b3cc59ceea246d3db93d076dc",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
[INFORMACION RECORTADA]
root@master01:~# 
```

  * Podemos ver la cantidad de informacion que obtenemos. Un dato interesante es la direccion IP del contenedor (172.17.0.2)

  * Probamos a realizar una peticion web a esa direccion con curl

```bash
root@master01:~# curl 172.17.0.2
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

  * Obtenemos la pagina por defecto de nginx. Nuestro servidor Web funciona!

## Conectividad exterior (Puertos)

  * La IP que obtuvimos en el paso anterior, pertenece a una red privada dentro del host (una red gestionada por docker). Pero, como nos conectamos desde fuera del host a ese contenedor?
    * Para eso, tenemos que "exponer" un puerto del host y conectarlo al contenedor, con la opcion "-p"

  * Paramos y eliminamos el contenedor anterior para arrancar (para hacer limpieza)

```bash
root@master01:~# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS     NAMES
a40912759484   nginx     "/docker-entrypoint.…"   30 minutes ago   Up 13 minutes   80/tcp    webserver
root@master01:~# docker stop webserver
webserver
root@master01:~# docker rm webserver
webserver
```

  * Ahora volvemos a ejecutar un contenedor igual, pero esta vez exponiendo el puerto 80 al exterior (OJO, para exponer el puerto 80 del host es necesario tener permisos de administrador (root). En caso de no tener permisos de administrador podemos hacerlo igual pero con el puerto 8000

```bash
root@master01:~# docker run -d --name webserver -p80:80 nginx
367b22ea3de07c916b2f2d8f157f3697099c8a6e115e40a9848f7f60b1aaca22
```

  * En este caso, le indicamos que conecte el puerto 80 del host al puerto 80 del contenedor (-p 80:80)

  * Ahora ya podemos conectarnos desde fuera a la IP del host en el puerto 80 (o desde el propio host a localhost)

```bash
root@master01:~# curl 127.0.0.1
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

## Variables de entorno

  * Una forma muy habitual de inyectar configuraciones en un contenedor, son las variables de entorno, que se pueden definir con la opcion "-e"

```bash
iroot@master01:~# docker run -eVARIABLE1="Una variable" -eVARIABLE2="Otra variable" alpine env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=ce16e5605f14
VARIABLE1=Una variable
VARIABLE2=Otra variable
HOME=/root
```

  * Podemos ver que en el entorno del proceso del contenedor, nos aparecen las variables que hemos definido al crearlo

## Persistencia de datos y Volumenes

  * Los contenedores estan diseñador para ser efímeros, es decir, que los datos que se almacenan en los mismos, no son persistentes. Una vez que se elimina el contenedor, los datos se pierden
  * Si necesitamos persistencia de datos, podemos utilizar el concepto de "volumenes" que consiste en conectar un directorio de la máquina física a un directorio del contenedor, de forma que cuando el contenedor "muere", los datos permanecen en dicho directorio

  * Arrancamos un contenedor nginx, mapeando /usr/share/nginx/html a un directorio local

```bash
root@master01:~# docker run -d -v/tmp/test_persistencia:/usr/share/nginx/html -p80:80 nginx
9d7e92535b59be5561dc30abf7ede660b94661ddfc8fb472b720950a1f4cfef9
root@master01:~# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                               NAMES
9d7e92535b59   nginx     "/docker-entrypoint.…"   4 minutes ago   Up 4 minutes   0.0.0.0:80->80/tcp, :::80->80/tcp   vigorous_wilbur
root@master01:~# 
```

  * Docker nos crea automaticamente el directorio /tmp/test_persistencia, que queda mapeado al directorio /usr/share/nginx/html del contenedor
  * Puesto que dicho contenedor esta vacio, una peticion al servidor web nos da error "403 permiso denegado" porque la accion por defecto en este caso es listar el contenido del directorio, pero dicha accion no esta permitida por seguridad

```bash
root@master01:~# ls /tmp/test_persistencia
root@master01:~# curl 127.0.0.1
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.21.3</center>
</body>
</html>
root@master01:~# 
```

  * Creamos un fichero index.html

```bash
root@master01:~# docker exec 9d7e92535b59 bash -c "echo 'PRUEBA DE PERSISTENCIA' > /usr/share/nginx/html/index.html"
root@master01:~# docker exec 9d7e92535b59 cat /usr/share/nginx/html/index.html
PRUEBA DE PERSISTENCIA
root@master01:~# 
```

  * Verificamos que nos muestra dicho fichero

```bash
root@master01:~# curl 127.0.0.1
PRUEBA DE PERSISTENCIA
root@master01:~#
```

  * Verificamos que el fichero nos aparece en el directorio del host

```bash
root@master01:~# ls /tmp/test_persistencia/
index.html
root@master01:~# cat /tmp/test_persistencia/index.html 
PRUEBA DE PERSISTENCIA
root@master01:~# 
```

  * Paramos y eliminamos el contenedor

```bash
root@master01:~# docker stop 9d7e92535b59
9d7e92535b59
root@master01:~# docker rm 9d7e92535b59
9d7e92535b59
root@master01:~# docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
root@master01:~# 
```

  * Verificamos que conservamos el fichero en el directorio del host

```bash
root@master01:~# ls /tmp/test_persistencia/
index.html
```

  * Arrancamos otro contenedor nginx

```bash
root@master01:~# docker run -d -v/tmp/test_persistencia:/usr/share/nginx/html -p80:80 nginx
8792c30636b3fadad0da73cc9c9e012d784eeef7cb3c11998d87ddd8a4287865
root@master01:~# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                               NAMES
8792c30636b3   nginx     "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds   0.0.0.0:80->80/tcp, :::80->80/tcp   angry_chandrasekhar
```

  * Verificamos que nos sirve el mismo fichero

```bash
root@master01:~# curl 127.0.0.1
PRUEBA DE PERSISTENCIA
```

  * Por lo tanto, con el mecanismo de "mapear" volumenes (opcion -v) conseguimos tener persistencia de datos utilizando directorios locales del host
    * NOTA: Docker tambien soporta otros tipos de volumenes persistentes aparte de los mapeos a directorio local, pero estan fuera del alcance de esta introduccion

## Creacion de imágenes (Dockerfile)

En esta seccion vamos a aprender a generar imágenes Docker personalizadas y publicarlas al registro público de dockerhub

Para nformacion mas completa, consultar referencia: https://docs.docker.com/engine/reference/builder/

Las opciones básicas del Dockerfile son las siguientes:

  * FROM: Indica la imagen base a partir de la cual vamos a construir la nuestra
  * ENV: Define variables de entorno dentro del contenedor (en tiempo de creacion de la imagen)
  * RUN: Ejecuta una orden dentro del contenedor
  * COPY: Copia recursivamente directorios al contenedor
  * ADD: Añade ficheros al contenedor. El origen puede ser una URL externa, o incluso un archico comprimido, que se descomprimira en el destino
  * EXPOSE: Es una opcion **informativa** que indica qué puerto expone el contenedor, para tenerlo en cuenta desde herramientas externas
  * USER: Indica que a partir de esa linea, todo lo que viene a continación se debe ejecutar como el usuario indicado
  * WORKDIR: Indica que a partir de esa linea, todo lo que viene a continación se debe ejecutar en el directorio indicado
  * ENTRYPOINT: Punto de entrada al contenedor (programa que se ejecutara)
  * CMD: Argumentos que se pasrán a ENTRYPOINT si no se especifica ninguno en la linea de comandos

  * Dockerfile basico

```Dockerfile
# Imagen base de la que partimos (se recomienda especificar siempre la version)
FROM ubuntu:18.04

# Definimos algunas variables de entorno
ENV VAR1 "Una variable"
ENV VAR2 "Otra variable"

# Actualizamos contenedor (y limpiamos datos intermedios)
RUN apt update  -y && apt upgrade -y && apt clean -y

WORKDIR /tmp
USER nobody
# Este fichero se creará en /tmp/fichero y el propietario sera "nobody"
RUN echo "Prueba" > fichero

ENTRYPOINT ["/bin/echo"] 
CMD ["Hola"]
```

  * Generamos la imagen

```bash
root@master01:~/test-dockerfile# docker build . -tdockerfile_test
Sending build context to Docker daemon  2.048kB
Step 1/9 : FROM ubuntu:18.04
18.04: Pulling from library/ubuntu
284055322776: Pull complete 
Digest: sha256:bfb4cabd667790ead5c95d9fe341937f0c21118fa79bc768d51c5da9d1dbe917
Status: Downloaded newer image for ubuntu:18.04
 ---> 5a214d77f5d7
Step 2/9 : ENV VAR1 "Una variable"
 ---> Running in df51cb26acb1
Removing intermediate container df51cb26acb1
 ---> ee4fcae9a01f
Step 3/9 : ENV VAR2 "Otra variable"
 ---> Running in 019b43e30947
Removing intermediate container 019b43e30947
 ---> 2ac831bc0ed9
Step 4/9 : RUN apt update  -y && apt upgrade -y && apt clean -y
 ---> Running in e35d67542dd4

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Get:1 http://archive.ubuntu.com/ubuntu bionic InRelease [242 kB]
Get:2 http://security.ubuntu.com/ubuntu bionic-security InRelease [88.7 kB]
[SALIDA RECORTADA]
Fetched 23.5 MB in 5s (4913 kB/s)
Reading package lists...
Building dependency tree...
Reading state information...
All packages are up to date.

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Reading package lists...
Building dependency tree...
Reading state information...
Calculating upgrade...
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Removing intermediate container e35d67542dd4
 ---> 4fc578c4d409
Step 5/9 : WORKDIR /tmp
 ---> Running in 07a3e65f1aae
Removing intermediate container 07a3e65f1aae
 ---> f949475312b2
Step 6/9 : USER nobody
 ---> Running in 0f8b51189b88
Removing intermediate container 0f8b51189b88
 ---> c6237b44c2e9
Step 7/9 : RUN echo "Prueba" > fichero
 ---> Running in 79ac7057e0ac
Removing intermediate container 79ac7057e0ac
 ---> eeb5cee24b0f
Step 8/9 : ENTRYPOINT ["/bin/echo"]
 ---> Running in d851b7d23823
Removing intermediate container d851b7d23823
 ---> 652563d17743
Step 9/9 : CMD ["Hola"]
 ---> Running in d32f9e78b165
Removing intermediate container d32f9e78b165
 ---> 5e4b725b66f1
Successfully built 5e4b725b66f1
Successfully tagged dockerfile_test:latest
```

  * El ENTRYPOINT indica que el contenedor simplemente escribira lo que le pasamos como parametro, u "Hola" si no le pasamos nada

```bash
root@master01:~/test-dockerfile# docker run -ti dockerfile_test 
Hola
root@master01:~/test-dockerfile# docker run -ti dockerfile_test Prueba
Prueba
root@master01:~/test-dockerfile# 
```

  * En esta imagen no podemos ejecutar un shell simplemente pasandole "bash" como parametro, como hemos hecho en algun ejemplo anterior, ya que en este caso, el parámetro (CMD) es sólo la cadena que se le pasa a "echo", con lo que simplemente imprime "bash"

```bash
root@master01:~/test-dockerfile# docker run -ti dockerfile_test bash
bash
```

  * En este caso, necestamos sobreescribir el ENTRIPOINT para que sea lo que queremos ejecutar (/bin/bash -l"

```bash
root@master01:~/test-dockerfile# docker run -ti --entrypoint "/bin/bash" dockerfile_test
nobody@7a180b856f75:/tmp$ ls -l
total 4
-rw-r--r-- 1 nobody nogroup 7 Oct 11 10:47 fichero
```

  * Ahora si que nos ejecuta el bash, y vemos que nos posiciona directamente en /tmp (debido a la opcion WORKDIR) y que existe el fichero generado, y su propietario es el usuario "nobody" (el especificado con la opcion USER antes de ejecutar la creacion del fichero)

## Subir imagenes a dockerhub (o otro repositorio)

Ya hemos generado la imagen, pero ahora solo existe en la máquina donde la hemos creado.
Para poder ejecutarla en otras maquinas (p.ej. en kubernetes) necesitamos subirla a un repositorio

  * Para indicar el repositorio donde queremos subirlo, etiquetamos la imagen

```bash
linux@master01:~/docker_test$ sudo docker images
REPOSITORY                           TAG        IMAGE ID       CREATED         SIZE
dockerfile_test                      latest     34bfcc076093   2 minutes ago   101MB
ubuntu                               18.04      5a214d77f5d7   10 days ago     63.1MB
linux@master01:~/docker_test$ docker tag dockerfile_test canarytek/dockerfile_test
linux@master01:~/docker_test$ sudo docker images
REPOSITORY                           TAG        IMAGE ID       CREATED         SIZE
canarytek/dockerfile_test            latest     efe7d07fca89   2 minutes ago   113MB
dockerfile_test                      latest     34bfcc076093   3 minutes ago   101MB
ubuntu                               18.04      5a214d77f5d7   10 days ago     63.1MB
```

  * Necesitamos tener una cuenta de usuario en dockerhub para subir imagenes. Una vez que la tenemos, iniciamos sesion

```bash
linux@master01:~/docker_test$ sudo docker login
```

  * Enviamos la imagen

```bash
linux@master01:~/docker_test$ sudo docker push canarytek/dockerfile_test
Using default tag: latest
The push refers to repository [docker.io/canarytek/dockerfile_test]
e9e628e15371: Pushed 
450bed632ad8: Pushed 
9f10818f1f96: Mounted from library/ubuntu 
27502392e386: Mounted from library/ubuntu 
c95d2191d777: Mounted from library/ubuntu 
latest: digest: sha256:c40f038f0fd9790ab2baa184333e54dfeae6d5627765e79e4b4c2d1f117d9216 size: 1362
```

  * A partir de este momento, podremos ejecutar esa imagen en cualquier maquina docker, indicando la imagen "canarytek/dockerfile_test"
    * "canarytek" es la organización o usuario que creó la imagen, y al no definir ningun registro, se asume que es dockerub
  * Tambien podríamos especificar un registro de imagenes distinto a dockerhub, indicandolo en el tag. 
    * Por ejemplo: canarytek.azurecr.io/canarytek/dockerfile_test 

