# Volumes

## Crear un Pod

  * Crear un Pod con un volumen de datos

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: busybox-sleeper
  name: busybox-sleeper
spec:
  containers:
  - image: busybox
    name: busybox-sleeper
    command:
    - sleep
    - "1000"
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
    - name: data
```

   * Escribir algo al volumen de datos

```
linux@master01:~$ kubectl exec -ti busybox-sleeper sh
/ # ls /data
/ # echo "Hola Mundo" > /data/hola.txt
/ # cat /data/hola.txt 
Hola Mundo
```

  * Borrar el pod y volver a crearlo
  * Volver a conectarse y verificar si los datos siguen estando ahi

```
linux@master01:~$ kubectl exec -ti busybox-sleeper sh
/ # ls /data
```

  * ¿Que ha pasado?
