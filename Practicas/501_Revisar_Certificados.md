# Revisar Certificados

## Ver Certificados de los componentes

  * Ver los certificados usados por kube-apiserver para todos sus roles:
    * Como apiserver
    * Como cliente de etcd
    * Como cliente de kubelet
  * ¿A qué nombre está emitido el certificado usado como apiserver?
  * ¿Que duración tienen los certificados?
  * ¿Qué duración tiene el certificado de la CA?
  * ¿Los certificados de etcd usan la misma CA que el resto?

## Resolver un problema

  * Generar un error problema con los certificados (mirar el script es trampa!!)

```
sh Practicas/Scripts/501_1_Break_Something.sh
```

  * Comprueba los Pods en ejecucion

```
kubectl get pod
```

  * ¿Funciona? ¿Que ha pasado?
  * Resuelve el problema. (Pista: nos han dicho que un "becario" estuvo actualizando el fichero manifest del Pod de etcd)

