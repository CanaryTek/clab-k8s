# Practicas de Namespaces

## Crear Namespace

  * Crear un Namespace "test"

```bash
kubectl create namespace test
```

  * Crear pod en ese namespace (nombre: nginx, image: nginx)

```bash
kubectl -n test run nginx --image nginx
```

  * Borrar el namespace "test"
    * ¿Que pasa con los objetos que habia en el NameSpace?

## Crear Namespace con Quotas

  * Crear Namespace "limited" limitando el numero de pods a 3

```
apiVersion: v1
kind: Namespace
metadata:
  name: limited
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: limited
spec:
  hard:
    pods: "3"
    limits.cpu: "16"
    limits.memory: 2Gi
    requests.cpu: "16"
    requests.memory: 2Gi
```

  * Definir deployment con 2 replicas

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: test
  name: test
  namespace: limited
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - image: nginx
        name: nginx
        resources:
          requests:
            memory: "50Mi"
            cpu: "5m"
          limits:
            memory: "50Mi"
            cpu: "5m"
```

  * Escalar deployment a 4 replicas

```
kubectl -n limited scale deploy test --replicas=4
```

  * ¿Se ejecutan las 4 replicas solicitadas? ¿Por que? (PISTA: El numero de replicas los gestiona el ReplicaSet (kubectl -n limited describe rs nombre-replicaset))
  * Modificar quota para poder hacerlo PISTA: Edita las quotas del namespace (kubectl -n limited edit). Es posible que necesites escalar el deployment a su tamaño inicial (3) y volver a escalarlo a 4 replicas para que se refresque el estado

