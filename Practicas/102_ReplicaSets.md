# Practicas de ReplicaSets

## Crear ReplicaSet

  * Ver pods en ejecucion
  * Crear un ReplicaSet

```bash
cat > replicaset.yaml << END
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  # modify replicas according to your case
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
END
kubectl apply -f replicaset.yaml
```

  * Ver pods
  * Ver en que nodos se estan ejecutando?

```bash
kubectl get pod -o wide
```

## Gestion de pods y replicas

  * Matar uno de los Pod

```bash
kubectl delete pod "pod_name"
```
    * ¿Que pasa?
  * Aumentar el numero de replicas
    * Opcion 1: Editar YAML + "kubectl apply" (PISTA: Modificar parámetro "replicas")
    * Opcion 2: con "kubectl scale"

```bash
kubectl scale --replicas=4 replicaset/frontend
```

  * Disminuir el numero de replicas

  * Eliminar ReplicaSet

```bash
kubectl delete replicaset frontend
```
    * ¿Que le pasa a los Pod?

## Resolver problemas

  * Ejecutar script 

```bash
sh Practicas/Scripts/101_2_Create_RS.sh
```

  * Cuantos Pods se estan ejecutando?
  * Hay algun problema? Cual? (PISTA: consulta los detalles de uno de los pods con "kubectl describe pod nombre-pod")
  * Arreglarlo (PISTA: Debes corregirlo en el ReplicaSet para que se aplique a todos los pod. Ademas, tendras que eliminar los pods erróneos para que el ReplicaSet arranque otros con la definición correcta)

## Resolver problemas con definicion

  * Crear otro RS con problemas

```bash
cat > replicaset2.yaml << END
apiVersion: v1
kind: ReplicaSet
metadata:
  name: new-rs2
  labels:
    app: test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
END
kubectl apply -f replicaset2.yaml
```

  * ¿Cual es el problema? (PISTA: hay mas de un error)
  * Arreglarlo para que los Pod arranquen (editando fichero yaml)
    * PISTA 1: En que API se definen los ReplicaSet?
    * PISTA 2: Recuerda que el ```matchLabels``` del ```seledctor``` debe coincidir con la ```label``` del ```template```

