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
  * ¿Arranca?
    * ¿En que estado se queda?

  * Crear un Pod indicando el nodeName (nombre: nginx2, image: nginx) 
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

