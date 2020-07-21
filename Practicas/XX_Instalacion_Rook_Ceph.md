# Instalacion de Ceph con Rook

https://rook.io/docs/rook/v1.3/ceph-quickstart.html

## Despliegue del Rook operator

  * Partimos de nodos worker con un disco dedicado para Ceph. En este caso es el /dev/vdb

```
for h in node{1,2,3}{1,2}; do echo "*** $h"; ssh -t linux@$h "lsblk" ; done
```

  * Clonamos repo git de Rook

```
git clone --single-branch --branch release-1.3 https://github.com/rook/rook.git
```

  * Desplegamos Rook operator (en instalaciones basicas no hay que editar nada)

```
cd rook/cluster/examples/kubernetes/ceph
kubectl create -f common.yaml
kubectl create -f operator.yaml
```

  * Esperamos a que se despliegue

```
kubectl get pod --all-namespaces -w
```

  * Nos debe haber creado un namespace rook-ceph, ver el contenido

```
kubectl -n rook-ceph get all
```

## Despliegue de un cluster Ceph

Una vez que tenemos Rook desplegado, podemos desplegar un cluster Ceph (desde el mismo directorio de arriba)

  * Si queremos limitar que solo algunos nodos sean nodos de almacenamiento, descomentamos lo siguiente en el cluster.yaml

```
  placement:
    all:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: role
              operator: In
              values:
              - storage-node
      podAffinity:
      podAntiAffinity:
      topologySpreadConstraints:
      tolerations:
      - key: storage-node
        operator: Exists
```

  * Con la configuracion anterior, debemos etiquetar los nodos que queramos que sean de almacenamiento con:

```
kubectl label node node11 role=storage-node
```

  * Desplegamos el cluster

```
kubectl apply -f cluster.yaml
```

  * Desplegamos el toolbox

```
kubectl create -f toolbox.yaml
```

  * Para las operaciones con Ceph nos podemos conectar al toolbox

```
kubectl -n rook-ceph exec -ti rook-ceph-tools-5754d4d5d-dcznh -- bash
[root@rook-ceph-tools-5754d4d5d-dcznh /]# ceph status
  cluster:
    id:     a332e5ef-7655-45af-bcc6-c7f18877d8cb
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum a,b,c (age 12m)
    mgr: a(active, since 11m)
    osd: 3 osds: 3 up (since 11m), 3 in (since 11m)
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   3.0 GiB used, 57 GiB / 60 GiB avail
    pgs:     
```

## Almacenamiento de bloques

  * Creamos el storageclass de block-storage

```
kubectl apply -f csi/rbd/storageclass.yaml
```

  * Verificamos que se ha creado

```
kubectl get sc
NAME              PROVISIONER                  RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
rook-ceph-block   rook-ceph.rbd.csi.ceph.com   Delete          Immediate           true                   19s
```

### Hacemos benchmarks

  * Descargamos el yaml

```
wget https://raw.githubusercontent.com/logdna/dbench/master/dbench.yaml
```

  * Lo editamos y cambiamos el StorageClass al queremos medir, en este caso: rook-ceph-block. Tambien cambiamos la imagen a canarytek/dbench:latest


