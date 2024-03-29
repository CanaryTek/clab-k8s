# Taints y Tolerations

## Plantilla

Aunque se puede encontrar en la doc de K8s, esta es la plantilla de la estructura de "tolerations"

```
tolerations:
- key:
  operator:
  value:
  effect:
```

## Taints a un nodo

  * Asignar Taint a los dos nodos worker (taint: os=windows:NoSchedule)

```bash
kubectl taint nodes node1 os=windows:NoSchedule
kubectl taint nodes node2 os=windows:NoSchedule
```

  * Arrancar un Pod (nombre: nginx1, imagen: nginx)
    * ¿En que estado esta el Pod? ¿Por que?
  * Eliminar el Taint del nodo02
    * ¿El pod cambia de estado? ¿Por que?
  * Arrancar 2 Pods mas (nombres nginx2 y nginx3)
    * ¿Alguno se arranca en el nodo01? ¿Por que?
    * Eliminar todos los Pods
  * Definir un Pod con "tolerancia" (Toleration) al Taint anterior
    * ¿Se arranca en el nodo01?
  * Definir otro Pod igual, con "tolerancia"
    * ¿Se arranca tambien en el nodo01?
    * Si se arranca en otro, ¿por que?

## Taints en Master

  * Ver los Taints del master
  * Ver los "Tolerations" de algun Pod que se este ejecutando en el master
  * Definir un Pod que se pueda ejecutar en el master

<details>
 <summary>Pistas</summary>
  
  * Ver detalles de un nodo
  ```
  kubectl describe node <nombre_nodo>
  ```
  * Ver detalles del pod de etcd
  ```
  kubectl -n kube-system describe pod etcd-master01
  ```
  * Definir pod con toleration
  ```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "op"
    operator: "Exists"
    effect: "NoExecute"
  ```

  </details>
