# Practicas de Deployment

En esta sección haremos prácticas únicamente del manejo básico del Deployment.
Las prácticas de actualizaciones, rollback, etc, las haremos en la sección de "Flujo de vida de aplicaciones"

## Crear Deployment

  * Ver pods en ejecucion
  * Crear un Deployment

```bash
cat > deployment1.yaml << END
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
END
kubectl apply -f deployment1.yaml
```

  * Ver Deployments
  * Ver ReplicaSets
  * Ver Pods
  * Ver en que nodos se estan ejecutando?

```bash
kubectl get pod -o wide
```

## Gestion de pods y replicas

  * Matar uno de los Pod
    * ¿Que pasa?
  * Aumentar el numero de replicas
    * Opcion 1: Editar YAML + "kubectl apply"
    * Opcion 2: con "kubectl scale"
  * Disminuir el numero de replicas

  * Eliminar Deployment
    * ¿Que le pasa a los Pod?

## Resolver problemas de definicion

  * Crear definicion

```bash
cat > deployment2.yaml << END
apiVersion: v1
kind: deployment
metadata:
  name: deployment1
spec:
  replicas: 2
  selector:
    matchLabels:
      name: busybox-pod
  template:
    metadata:
      labels:
        app: busybox-pod
    spec:
      containers:
      - name: busibox-container
        image: busybox7
        command:
        - sh
        - "-c"
        - echo Hello Kubernetes! && sleep 3600

END
kubectl apply -f deployment2.yaml
```

  * ¿Cual es el problema? (puede haber mas de uno)
  * Arreglarlo (editando fichero yaml)

