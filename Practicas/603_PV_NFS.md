# Almacenamiento en NFS

En esta practiva vamos a configurar el proveedor de almacenamiento persistente mas sencillo: NFS

Realmente hay dos formas de utilizar NFS como almacenamiento persistente:

  * Montar en todos los nodos un volumen NFS (p. ej. en /pv) y definir los PV como hostPath bajo ese directorio
  * Usar el driver nativo de NFS

El primer enfoque es trivial porque sólo habria que configurar los nodos y definir los PV como lo hemos hecho en la practica anterior

En esta practica usaremos el segundo enfoque

## Montar un servidor NFS en el nodo master

Se supone que para usar NFS debemos tener ya un servidor NFS tolerante a fallos, pero para esta práctica usaremos el nodo master como servidor NFS

  * Instalamos el servidor

```
sudo apt-get install -y nfs-kernel-server
```

  * Creamos el directorio /nfs que es el que usaremos como almacenamiento

```
sudo mkdir /nfs
```

  * Creamos el export en el /etc/exports

```
/nfs	192.168.124.0/24(rw,sync,no_subtree_check)
```

  * Forzamos recarga de exports

```
sudo exportfs -a -v
```

  * En los nodos, instalamos nfs-client y verificamos que podemos montarlo

```
sudo apt-get install nfs-client
sudo mount master01:/nfs /mnt
```

## Creamos PV en NFS

  * Preparar directorio NFS para el PV

```
sudo mkdir /nfs/data1
sudo chmod 777 /nfs/data1
```

  * Crear un PV pv-data de 100Mi ReadWriteMany en NFS /nfs/data1

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  nfs:
    path: /nfs/data1
    server: 172.17.0.2
```

A partir de aqui podemos repetir la practica anterior, pero en este caso el PV es visible desde cualquier nodo

## Diferencia entre tipos de acceso

  * Preparamos directorio para PV con AccessMode ReadWriteOnce

```
sudo mkdir /nfs/rwo
sudo chmod 777 /nfs/rwo
```

  * Crear un PV y un PVC para AccessMode ReadWriteOnce

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-rwo
spec:
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /nfs/rwo
    server: master01
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs-rwo
spec:
  resources:
    requests:
      storage: 50Mi
  accessModes:
    - ReadWriteOnce
```

  * Crear un deployment de nginx con multiples replicas y los datos en el volumen anterior

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
        volumeMounts:
          - name: data
            mountPath: /usr/share/nginx/html
      volumes:
          - name: data
            persistentVolumeClaim:
              claimName: pvc-nfs-rwo
```

  * ¿Arrancan todos los Pods? ¿Por que? ¿No se supone que es ReadWriteOnce?

  * Crear servicio

```
kubectl expose deploy nginx --port 80 --type LoadBalancer
```

  * Crear un index.html en /nfs/rwo

```
echo HOLA_MUNDO > /nfs/rwo/index.html
```

  * Acceder con el navegador a la IP del servicio y verificar que vemos la pagina creada
