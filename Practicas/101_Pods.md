# Practicas de Pods

## Creacion de Pod (imperativo)

  * Ver pods en ejecucion
  * Crear un pod con nombre nginx basado en imagen nginx

```bash
kubectl run nginx --image=nginx
```

  * Ver caracteristicas del Pod (describe)

```bash
kubectl describe pod nginx
```

  * Ejecutar otro pod igual (misma orden)
    * ¿Algun problema? ¿Como lo podemos resolver? (PISTA: Cambia el parametro de da conflicto)
  * Ver en que nodos se estan ejecutando

```bash
kubectl get pod -o wide
```

## Pods con multiples contenedores

  * Ejecutar Script (genera un Pod)

```bash
sh Practicas/Scripts/101_1_Create_Pod.sh
```

  * Ver numero de contenedores del pod
  * Ver el estado
    * ¿Cual es el problema?
  * Ver columna READY. ¿Que significa?
  * ¿Podemos arreglarlo? (PISTA: Edita el pod y revisa el nombre de la imagen del contenedor que falla. Exisre un software que se llama "redis")

```bash
kubectl edit pod "nombre_pod"
```

## Definir Pod desde YAML

  * Crear un Pod creando su definicion YAML (nombre redis, image redisXX)

```bash
cat > pod.yaml << END
apiVersion: v1
kind: Pod
metadata:
  name: redis
  labels:
    app: redis
spec:
  containers:
  - name: redis
    image: redisXX
END
kubectl apply -f pod.yaml
```

  * ¿Arranca? ¿Por que? (PISTA: Problema similar a la práctica anterior)
  * Arreglar el Pod editando el YAML y ejecutando apply, o mediante kubectl edit 

