# Practicas de Namespaces

## Crear Namespace

  * Crear un Namespace "test"
  * Crear pod en ese namespace (nombre: nginx, image: nginx)
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

  * ¿Que pasa? (PISTA: kubectl -n limited describe rs test)
  * Modificar quota para poder hacerlo

