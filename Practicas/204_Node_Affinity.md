# Node Affinity

## Plantilla

Aunque se puede encontrar en la doc de K8s, esta es la plantilla de la estructura de "nodeAffinity"

```
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key:
            operator:
            values:
```

## Node Affinity simple

  * Etiquetar un nodo
```bash
kubectl label nodes node01 size=Large
```
  * Crear deployment de 4 replicas
  * Assignar nodeAffinity para que el deployment anterior se ejecute solo en el nodo etiquetado

## Taints/Tolerations y Node Affinity

  * Configurar lo necesario para conseguir el siguiente escenario
    * Tener un Pod "red", con imagen nginx, que se ejecute exclusivamente en el nodo01
    <details>
<summary>Pista</summary>
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
   </details>

    * Que cualquier otro Pod (sin necesidad de definir nada en el Pod, se ejecute en el nodo02, o cualquier nodo adicional si aumentamos el cluster

