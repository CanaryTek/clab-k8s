# Manual Scheduling

  * Forzar fallo del scheduler (ya veremos por que esto funciona...)

```bash
sudo mv /etc/kubernetes/manifests/kube-scheduler.yaml /tmp
```

  * Verificar que ya no se esta ejecutando el scheduler

```bash
kubectl get pod -n kube-system
```

  * Crear un Pod sin indicar el nodeName (nombre: nginx1, image: nginx)

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx1
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
```

  * ¿Arranca?
    * ¿En que estado se queda?

  * Crear un Pod indicando el nodeName (nombre: nginx2, image: nginx) 

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx2
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  nodeName: node02
```

  * ¿Arranca?
    * ¿En que estado se queda?

  * Resolver el error del scheduler

```bash
sudo mv /tmp/kube-scheduler.yaml /etc/kubernetes/manifests/
```
  * Verificar que se arranca el scheduler

```bash
kubectl get pod -n kube-system
```

  * Comprobar estado de los Pods
    * ¿Que ha pasado?

