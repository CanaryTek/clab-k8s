# StatefulSets vs Deployments

Esta practica tiene como objetivo observar la diferencia de comportamientos de un StatefulSet con respecto a un Deployment

**NOTA:** Esta práctica asume que estamos en un cluster en Azure con el provider CSI para almacenamiento azurefile

  * Creamos un deployment con un PVC

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: counter
spec:
  replicas: 2
  selector:
    matchLabels:
      app: counter
  template:
    metadata:
      labels:
        app: counter
    spec:
      containers:
      - name: counter
        image: "kahootali/counter:1.1"
        volumeMounts:
        - name: counter
          mountPath: /app/
      volumes:
      - name: counter
        persistentVolumeClaim:
          claimName: counter
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: counter
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 50Mi
  storageClassName: azurefile-csi
```

  * Vemos que nos crea un PVC para todos los pods (ReadWriteMany), y que crea los pods en paralelo

```bash
linux@master01:~$ kubectl apply -f deploy.yaml 
deployment.apps/counter created
persistentvolumeclaim/counter created
linux@master01:~$ kubectl get pod
NAME                       READY   STATUS              RESTARTS   AGE
counter-7f6666d96c-nsj99   0/1     ContainerCreating   0          3s
counter-7f6666d96c-qjqb4   0/1     ContainerCreating   0          3s
linux@master01:~$ kubectl get pod -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
counter-7f6666d96c-nsj99   1/1     Running   0          7s    10.40.0.2   node02   <none>           <none>
counter-7f6666d96c-qjqb4   1/1     Running   0          7s    10.32.0.3   node01   <none>           <none>
linux@master01:~$ kubectl get pvc
NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE
counter   Bound    pvc-8e1840c9-9043-4e30-80c8-16835af164ff   50Mi       RWX            azurefile-csi   12s
```

  * Creamos un StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: counter
spec:
  serviceName: "counter-app"
  selector:
    matchLabels:
      app: counter
  replicas: 2
  template:
    metadata:
      labels:
        app: counter
    spec:      
      containers:
      - name: counter
        image: "kahootali/counter:1.1"  
        volumeMounts:
        - name: counter
          mountPath: /app/      
  volumeClaimTemplates:
  - metadata:
      name: counter
    spec:
      accessModes: [ "ReadWriteMany" ]
      storageClassName: azurefile-csi
      resources:
        requests:
          storage: 50Mi
```

  * Vemos que en este caso nos crea un PVC para cada pod, que los nombres son predecibles, y que arranca los pods en orden

```bash
linux@master01:~$ kubectl apply -f statefulset.yaml
statefulset.apps/counter created
linux@master01:~$ kubectl get pod -o wide
NAME                       READY   STATUS              RESTARTS   AGE     IP          NODE     NOMINATED NODE   READINESS GATES
counter-0                  0/1     ContainerCreating   0          2s      <none>      node02   <none>           <none>
counter-7f6666d96c-nsj99   1/1     Running             0          4m27s   10.40.0.2   node02   <none>           <none>
counter-7f6666d96c-qjqb4   1/1     Running             0          4m27s   10.32.0.3   node01   <none>           <none>
linux@master01:~$ kubectl get pod -o wide
NAME                       READY   STATUS              RESTARTS   AGE     IP          NODE     NOMINATED NODE   READINESS GATES
counter-0                  1/1     Running             0          7s      10.40.0.3   node02   <none>           <none>
counter-1                  0/1     ContainerCreating   0          3s      <none>      node01   <none>           <none>
counter-7f6666d96c-nsj99   1/1     Running             0          4m32s   10.40.0.2   node02   <none>           <none>
counter-7f6666d96c-qjqb4   1/1     Running             0          4m32s   10.32.0.3   node01   <none>           <none>
linux@master01:~$ kubectl get pod -o wide
NAME                       READY   STATUS    RESTARTS   AGE     IP          NODE     NOMINATED NODE   READINESS GATES
counter-0                  1/1     Running   0          9s      10.40.0.3   node02   <none>           <none>
counter-1                  1/1     Running   0          5s      10.32.0.4   node01   <none>           <none>
counter-7f6666d96c-nsj99   1/1     Running   0          4m34s   10.40.0.2   node02   <none>           <none>
counter-7f6666d96c-qjqb4   1/1     Running   0          4m34s   10.32.0.3   node01   <none>           <none>
linux@master01:~$ kubectl get pvc
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE
counter             Bound    pvc-8e1840c9-9043-4e30-80c8-16835af164ff   50Mi       RWX            azurefile-csi   4m41s
counter-counter-0   Bound    pvc-bf6d6ffe-dd2c-46b6-8491-4fbdadc4f5bd   50Mi       RWX            azurefile-csi   16s
counter-counter-1   Bound    pvc-eb1892aa-b881-4095-92cd-209d30e340e7   50Mi       RWX            azurefile-csi   12s
```
