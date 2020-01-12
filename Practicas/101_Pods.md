# Practicas de Pods

## Creacion de Pod (imperativo)

  * Ver pods en ejecucion
  * Crear un pod con nombre nginx basado en imagen nginx

```bash
kubectl run nginx --image nginx --generator run-pod/v1
```

  * Ver caracteristicas del Pod (describe)
  * Ejecutar 2 pods mas (iguales)
    * ¿Algun problema? ¿Como lo podemos resolvemos?
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
  * ¿Podemos arreglarlo? (kubectl edit)
 
## Definir Pod desde YAML

  * Crear un Pod creando su definicion YAML (nombre redis, image redisXX)
  * ¿Arranca? ¿Por que?
  * Arreglar el Pod editando el YAML y ejecutando apply, o mediante kubectl edit 

