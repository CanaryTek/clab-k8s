# Solucion a la practica 204_2 de Node Affinity

Configurar lo necesario para conseguir el siguiente escenario

  * Tener un Pod "red", con imagen nginx, que se ejecute exclusivamente en el nodo01
  * Que cualquier otro Pod (sin necesidad de definir nada en el Pod, se ejecute en el nodo02, o cualquier nodo adicional si aumentamos el cluster

## Solucion

  * Necesitamos que el Pod "red" se ejecute en el nodo node01. Por tanto necesitaremos una definicion de nodeAffinity que nos vincule el pod a un label del node01
  * Necesitamos hacer que el pod "red" se el unico pod que se ejecuta en  node01. Por tanto necesitaremos un "Taint" en ese nodo, y un "Toleration" a ese Taint en el pod red

  * Añadimos un label al node (para el nodeAffinity)

```
kubectl label node node01 color=red
```

  * Añadimos un Taint al nodo

```
kubectl taint node node01 color=red:NoSchedule
```

  * Definimos el Affinity y Toleration

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    color: red
  name: red
spec:
  containers:
  - image: nginx
    name: nginx
  tolerations:
  - key: "color"
    operator: "Equal"
    value: "red"
    effect: "NoSchedule"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: color
            operator: In
            values:
            - red
```

