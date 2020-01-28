# PersistentVolumes y PersistentVolumeClaims

## Crear PV y PVC

  * Crear un PV pv-data de 100Mi ReadWriteMany en hostpath /pv/data

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /pv/data
```

  * Crear un PVC para usar el PV anterior

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-data-1
spec:
  resources:
    requests:
      storage: 50Mi
  accessModes:
    - ReadWriteOnce
```

  * ¿En que estado esta el PVC? ¿En que estado esta el PV? ¿Por que no se asocia al PV anterior?
    * Arreglarlo adaptando el PVC en lo que sea necesario
  * Una vez arreglado, ¿En que estado quedan el PV y el PVC?
    * ¿Que espacio hay disponible en el PVC?

## Crear Pod que use un PVC

  * Crear un Pod para usar el PVC anterior

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
      persistentVolumeClaim:
        claimName: my-claim-1
```

  * ¿En que estado esta el Pod? ¿Por que?
    * Resolver el problema

## Escribir datos y verificar que es "persistente"

   * Escribir algo al volumen de datos

```
linux@master01:~$ kubectl exec -ti busybox-sleeper sh
/ # ls /data
/ # echo "Hola Mundo" > /data/hola.txt
/ # cat /data/hola.txt 
Hola Mundo
```

  * ¿En que nodo estan los datos?

```
ssh node01 ls /pv/data
ssh node02 ls /pv/data
```

  * Borrar el Pod y volver a crearlo, pero forzando que se ejecute en el nodo donde estan los datos
    * Pista: Definir nodeName
  * ¿Los datos siguen ahi?

  * Borrar el Pod y volver a crearlo, pero forzando que se ejecute **en el otro nodo**
    * Pista: Definir nodeName
  * ¿Los datos siguen ahi?
  * ¿Nos vale el tipo de volumen hostPath como solucion de PV?

## Borrar PVC

  * Borrar PVC en uso. ¿En que estado queda? (Si la terminal no responde, abre otras sesion SSH)
  * Eliminar el Pod de arriba. ¿Que pasa con el PVC? ¿y con el PV?
  * Vuelve a crear el PVC. ¿En que estado queda? ¿Por que no se enlaza al PV?
    * ¿Que atributo del PV deberiamos cambiar para que los PV se reutilicen?

