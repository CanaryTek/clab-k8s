# StatefulSet con local PV

Esta practica tiene como objetivo ver el comportamiento de los local PV con un StatefulSet

  * Creamos un StatefulSet con 2 replicas

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: local-pv-user
spec:
  serviceName: local-pv-user
  selector:
    matchLabels:
      app: local-pv-user
  replicas: 2
  template:
    metadata:
      labels:
        app: local-pv-user
    spec:      
      containers:
      - name: nginx
        image: "nginx"  
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html/      
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: local-storage
      resources:
        requests:
          storage: 1Gi
```

  * Como podemos ver arriba, el StatefulSet incluye una seccion "volumeClaimTemplates" porque a cada pod se le creara tambien un PVC

  * Aplicamos el fichero

```bash
linux@master01:~$ kubectl apply -f ss.yaml 
statefulset.apps/local-pv-user configured
linux@master01:~$ kubectl get pod
NAME              READY   STATUS    RESTARTS   AGE
local-pv-user-0   0/1     Pending   0          6m26s
linux@master01:~$ kubectl get pvc
NAME                   STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS    AGE
data-local-pv-user-0   Pending                                                      9s
```

  * Como podemos ver, se nos queda el Pod local-pv-user-0 en estado Pending, y nos ha aparecido tambien un PVC llamado data-local-pv-user-0
  * Lo primero que nos puede llamar la atencion es que, a pesar de definir "replicas: 2", solo tenemos un Pod en espera de arrancar y un PVC. Esto es debido al comportamiento ya comentado de los StatefulSet, que siempre arrancan en orden. hasta que no arranque la replica "local-pv-user-0" no se intentara arrancar la siguiente replica "local-pv-user-1"

  * La razon de que el Pod este en estado Pending, es que el PVC tambien esta en Pending porque no encuentra ningun PV que pueda usar

```bash
linux@master01:~$ kubectl describe pvc data-local-pv-user-0
Name:          data-local-pv-user-0
Namespace:     default
StorageClass:  
Status:        Pending
Volume:        
Labels:        app=local-pv-user
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      
Access Modes:  
VolumeMode:    Filesystem
Used By:       local-pv-user-0
Events:
  Type    Reason         Age               From                         Message
  ----    ------         ----              ----                         -------
  Normal  FailedBinding  3s (x3 over 23s)  persistentvolume-controller  no persistent volumes available for this claim and no storage class is set
```

  * Como podemos ver, no encuantra PV disponibles, y no tiene definida una StorageClass (por si tuvieramos provisionadores dinamicos)

  * Vamos a usar PV locales asociados a cada nodo, vinculando el PV al PVC que nos ha creado el StatefulSet

  * Creamos un PV local asociado al nodo node01. Por las reglas de afinidad que definimos, esto hara que el Pod que esta en estado Pending se arranque donde esta ese PV local, es decir, en node01

```yaml
iapiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-node01
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  local:
    path: /var/tmp/local-pv
  claimRef:
    name: data-local-pv-user-0
    namespace: default
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node01
```

  * Creamos los directorios que vamos a usar como volumen local en los nodos
    * OJO! la ruta y permisos estan definidos a efectos demostrativos, no usar algo asi en produccion

```bash
linux@master01:~$ ssh node01 "sudo mkdir /var/tmp/local-pv; sudo chmod 777 /var/tmp/local-pv"
linux@master01:~$ ssh node02 "sudo mkdir /var/tmp/local-pv; sudo chmod 777 /var/tmp/local-pv"
```

  * Aplicamos la definicion del OPV local

```bash
linux@master01:~$ kubectl apply -f  local-pv-node01.yaml 
persistentvolume/local-pv-node01 created
linux@master01:~$ kubectl get pvc
NAME                   STATUS   VOLUME            CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-local-pv-user-0   Bound    local-pv-node01   1Gi        RWO                           4m24s
linux@master01:~$ kubectl get pv
NAME              CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                          STORAGECLASS   REASON   AGE
local-pv-node01   1Gi        RWO            Delete           Bound    default/data-local-pv-user-0                           86s
```

  * Vemos que efectivamente nos crea el PV y lo vincula a nuestra PVC "data-local-pv-user-0"
  * Si miramos ahora nustros Pods, el Pod que estaba en estado pending deberia estar ejecutandose en el nodo node01, que es donde vinculamos el PV local

```bash
linux@master01:~$ kubectl get pod -o wide
NAME              READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
local-pv-user-0   1/1     Running   0          80s   10.40.0.2   node01   <none>           <none>
local-pv-user-1   0/1     Pending   0          44s   <none>      <none>   <none>           <none>
```

  * Vemos que, efectivamente ya ha podido arrancar el pod en node01, y ya nos aparece la segunda replica en estado Pending, porque tiene el mismo problema que tenia la primera: su PVC no encuentra ningun PV que pueda utilizar

```bash
linux@master01:~$ kubectl get pvc
NAME                   STATUS    VOLUME            CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-local-pv-user-0   Bound     local-pv-node01   1Gi        RWO                           2m56s
data-local-pv-user-1   Pending                                                              2m20s
linux@master01:~$ kubectl describe pvc data-local-pv-user-1
Name:          data-local-pv-user-1
Namespace:     default
StorageClass:  
Status:        Pending
Volume:        
Labels:        app=local-pv-user
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      
Access Modes:  
VolumeMode:    Filesystem
Used By:       local-pv-user-1
Events:
  Type    Reason         Age                  From                         Message
  ----    ------         ----                 ----                         -------
  Normal  FailedBinding  6s (x11 over 2m29s)  persistentvolume-controller  no persistent volumes available for this claim and no storage class is set
 ```

  * Para que arranque la segunda replica, necesitamos crear otro PV local. Como queremos tener tolerancia a fallos, lo que hacemos es vincular este segundo PV local al otro nodo, de forma que si nos falla un nodo, mantendamos activa la replica del otro nodo

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-node02
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  local:
    path: /var/tmp/local-pv
  claimRef:
    name: data-local-pv-user-1
    namespace: default
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node02
```

  * Aplicamos la definicion del nuevo volumen local de node02

```bash
linux@master01:~$ kubectl apply -f local-pv-node02.yaml 
persistentvolume/local-pv-node02 created
linux@master01:~$ kubectl get pvc
NAME                   STATUS   VOLUME            CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-local-pv-user-0   Bound    local-pv-node01   1Gi        RWO                           6m15s
data-local-pv-user-1   Bound    local-pv-node02   1Gi        RWO                           5m39s
linux@master01:~$ kubectl get pv
NAME              CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                          STORAGECLASS   REASON   AGE
local-pv-node01   1Gi        RWO            Delete           Bound    default/data-local-pv-user-0                           6m
local-pv-node02   1Gi        RWO            Delete           Bound    default/data-local-pv-user-1                           15s
```

  * Vemos que se nos crea el volumen y se vincula al PVC de la segunda replica

  * Si ahora consultamos el estado de los Pods

```bash
linux@master01:~$ kubectl get pod -o wide
NAME              READY   STATUS    RESTARTS   AGE     IP          NODE     NOMINATED NODE   READINESS GATES
local-pv-user-0   1/1     Running   0          6m37s   10.40.0.2   node01   <none>           <none>
local-pv-user-1   1/1     Running   0          6m1s    10.38.0.2   node02   <none>           <none>
```

  * Vemos que ya hemos conseguido nuestro objetivo de tener 2 replicas, cada una ejecutandose con un PersistentVolume local en ambos nodos

