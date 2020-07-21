# Almacenamiento local con LocalPersistentVolumes

https://kubernetes.io/blog/2019/04/04/kubernetes-1.14-local-persistent-volumes-ga/

En estos ejemplos, desplegaremos un StatefulSet de 3 replicas de nginx, con almacenamiento persistente en almacenamiento local de los nodos

## Opcion 1: Local PV creados manualmente

Crear los volumenes a mano y mapearlos manualmente al pvc

### Creamos los PV en los nodos

En este ejemplo vamos a suponer que los local PV los creamos en los nodos node11, node21 y node31

  * En todos los nodos, creamos (o montamos) el directorio donde almacenaremos los datos, en nuestro caso /mnt/data/vol00

```
for h in node{1,2,3}1; do echo "*** $h"; ssh -t linux@$h "mkdir -p /mnt/data/vol00" ; done
```

  * Definimos los PV

```
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv01
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/data/vol00
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node11
  claimRef:
     namespace: default
     name: www-web-0
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv02
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/data/vol00
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node21
  claimRef:
     namespace: default
     name: www-web-1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv03
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/data/vol00
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node31
  claimRef:
     namespace: default
     name: www-web-2
```

  * Los datos más relevantes de los PV son:
    * local.path: indicamos el directorio local donde se almacenaran los datos (es de tipo Filesystem)
    * nodeAffinity: indicamos en que nodo queremos que se cree el volumen
    * storageClassName y accessModes: debe coincidir con la definida en el volumeClaimTemplates del StatefulSet
    * persistentVolumeReclaimPolicy: usamos "Retain" para conservar los datos en caso de borrado accidental del PVC. Habria que borrarlos manualmente si realmente queremos inicializar el almacenamiento
    * claimRef: apunta al PersistentVolumeClaim al que queremos que se "conecte" este PV. Usamos el namespace y el nombre del PVC usado por el StatefulSet

### Desplegamos StatefulSet

  * Creamos el siguiente StatefulSet

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx 
  serviceName: "nginx"
  replicas: 3 
  template:
    metadata:
      labels:
        app: nginx 
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "local-storage"
      resources:
        requests:
          storage: 1Gi
  * Creamos el siguiente StatefulSet
```

Deberian engancharse los PVC a los PV creados en el apartado anterior, y deberian arrancar las 3 replicas

Ademas, los pods deberían arrancarse en los nodos donde hemos creado los PV

## Ocion 2: Provisionador dinámico

### Instalamos provisioner

  * Clonamos repo

```
git clone --depth=1 https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner.git
```

  * Creamos el manifest yaml a partir del chart

```
cd sig-storage-local-static-provisioner
helm template localprovisioner ./helm/provisioner --namespace kube-system > local-volume-provisioner.generated.yaml
```

  * Desplegamos el yaml generado

```
kubectl apply -f local-volume-provisioner.generated.yaml
```

  * Verificamos que se estan ejecutando los pod

```
kubectl -n kube-system get all
```

  * Creamos la storage class

```
kubectl apply -f deployment/kubernetes/example/default_example_storageclass.yaml
```

### Preparar almacenamiento

  * En los nodos hay que preparar el almacenamiento

  * Con la config por defecto espera "descubrir" los volumenes en /mnt/fast-disks/, pero tienen que ser mountpoints (o dispositivos de bloques), no directorios
  * Podemos "simular" el uso en filesystem ejecutando en cada nodo lo siguiente:

```
mkdir /mnt/data
for i in {00..09}; do mkdir -p /mnt/data/vol${i} /mnt/fast-disks/vol${i}; done
for i in {00..09}; do mount --bind /mnt/data/vol${i} /mnt/fast-disks/vol${i}; done
```

  * Con lo anterior, creamos 10 directorios en /mnt/data/volXX y lo "enlazamos" (con mount --bind) al directorio donde espera encontrarlos el local provisioner

  * Tras esta operacion, deberiamos ver 10 PV por cada nodo que tengamos

## StatefulSet con Local PV

Vamos a ver el comportamiento del local PV con un StatefulSet

  * Definimos el siguiente StatefulSet

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx
  serviceName: "nginx"
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "fast-disks"
      resources:
        requests:
          storage: 1Gi
```

  * Es fundamental que la StorageClass sea la que hemos definido en los pasos anteriores, y que esta asociada al local provisioner

  * Una vez que se completa el despliegue, deberiamos tener 3 pods ejecutandose en diferentes nodos. Cada uno de ellos consumiendo un PV local del nodo

```
linux@master11:~$ kubectl get pod -o wide
NAME    READY   STATUS    RESTARTS   AGE     IP          NODE     NOMINATED NODE   READINESS GATES
web-0   1/1     Running   0          2m27s   10.42.0.2   node11   <none>           <none>
web-1   1/1     Running   0          2m23s   10.39.0.5   node21   <none>           <none>
web-2   1/1     Running   0          2m20s   10.37.0.5   node32   <none>           <none>
```

### Comportamiento ante fallos

Vamos a ver cómo se comporta ante diferentes tipos de fallo:

**Fallo de un Pod**

  * Borramos uno de los pod: deberia arrancarse siempre en el mismo nodo, porque es el que tiene el PV

**Fallo de un nodo**

  * Apagamos el uno de los nodos
  * Al rato (puede tardar minutos), aparecera el nodo como NotReady y el Pod como "terminating"

```
linux@master11:~$ kubectl get node
NAME       STATUS     ROLES    AGE     VERSION
master11   Ready      master   6d17h   v1.18.5
master21   Ready      master   6d17h   v1.18.5
master31   Ready      master   6d17h   v1.18.5
node11     NotReady   <none>   6d17h   v1.18.5
node12     Ready      <none>   6d17h   v1.18.5
node21     Ready      <none>   6d17h   v1.18.5
node22     Ready      <none>   6d17h   v1.18.5
node31     Ready      <none>   6d17h   v1.18.5
node32     Ready      <none>   6d17h   v1.18.5
linux@master11:~$ kubectl get pod -o wide
NAME    READY   STATUS        RESTARTS   AGE     IP          NODE     NOMINATED NODE   READINESS GATES
web-0   1/1     Terminating   0          7m52s   10.42.0.2   node11   <none>           <none>
web-1   1/1     Running       0          14m     10.39.0.5   node21   <none>           <none>
web-2   1/1     Running       0          14m     10.37.0.5   node32   <none>           <none>
```

  * El Pod se quedará en ese estado indefinidamente porque el nodo no responde, si sabemos que el nodo no va a responder, podemos "vaciar el nodo" (hasta aqui no es diferente al uso de PV globles)

```
kubectl drain node11 --ignore-daemonsets --delete-local-data --force --grace-period=0
```

  * Tras la operacion anterior, k8s da por "muerto" el nodo, e intenta levantar el Pod en otro nodo

```
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
web-0   0/1     Pending   0          81s   <none>      <none>   <none>           <none>
web-1   1/1     Running   0          19m   10.39.0.5   node21   <none>           <none>
web-2   1/1     Running   0          19m   10.37.0.5   node32   <none>           <none>
```

  * Pero se queda en "Pending" porque no puede enlazarse al pvc que estaba usando, ya que estaba "enganchado" (bound) a un PV local que estaba en ese nodo. Si hacemos un "describe" de dicho Pod, veremos el siguiente error:

```
  Warning  FailedScheduling  <unknown>  default-scheduler  0/9 nodes are available: 1 node(s) were unschedulable, 3 node(s) had taint {node-role.kubernetes.io/master: }, that the pod didn't tolerate, 5 node(s) had volume node affinity conflict.
```

  * Vemos a que pv estan enganchados los pvc

```
linux@master11:~$ kubectl get pvc
NAME        STATUS   VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS   AGE
www-web-0   Bound    local-pv-c44d0c68   39Gi       RWO            fast-disks     25m
www-web-1   Bound    local-pv-de63bfd2   39Gi       RWO            fast-disks     25m
www-web-2   Bound    local-pv-53440dc    39Gi       RWO            fast-disks     25m
```

  * Para resolverlo, tenemos que eliminar el pvc y volver a crearlo, para que se enganche a un PV en otro nodo, aunque por supuesto, hemos perdido los datos
  * Una ver que hemos borrado el pvc de ese Pod, y lo volvamos a crear, el Pod arrancara en otro nodo

```
linux@master11:~$ kubectl get pod -o wide
NAME    READY   STATUS    RESTARTS   AGE     IP          NODE     NOMINATED NODE   READINESS GATES
web-0   1/1     Running   0          6m36s   10.40.0.5   node12   <none>           <none>
web-1   1/1     Running   0          24m     10.39.0.5   node21   <none>           <none>
web-2   1/1     Running   0          24m     10.37.0.5   node32   <none>           <none>
```

  * Podemos ver que ahora el pvc esta enganchado a otro pv

```
linux@master11:~$ kubectl get pvc
NAME        STATUS   VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS   AGE
www-web-0   Bound    local-pv-ec50371f   39Gi       RWO            fast-disks     73s
www-web-1   Bound    local-pv-de63bfd2   39Gi       RWO            fast-disks     25m
www-web-2   Bound    local-pv-53440dc    39Gi       RWO            fast-disks     25m
```

  * Vemos el estado de los PV locales

```
linux@master11:~$ kubectl get pv | grep -v Available
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM               STORAGECLASS   REASON   AGE
local-pv-53440dc    39Gi       RWO            Delete           Bound       default/www-web-2   fast-disks              29m
local-pv-c44d0c68   39Gi       RWO            Delete           Released    default/www-web-0   fast-disks              11h
local-pv-de63bfd2   39Gi       RWO            Delete           Bound       default/www-web-1   fast-disks              30m
local-pv-ec50371f   39Gi       RWO            Delete           Bound       default/www-web-0   fast-disks              30m
```

  * Como podemos ver, el pv que usaba anteriormente el pvc del Pod que falló (www-web-0), aparece ahora como "Released" porque hemos borrado el pvc que lo usaba.

