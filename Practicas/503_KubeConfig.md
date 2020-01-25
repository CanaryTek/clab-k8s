# KubeConfig

## Control de varios clusters

Unirse cada 2 grupos y cada uno configurar su kubeconfig para poder controlar su cluster y el del otro grupo

Pistas:

  * Pueden copiar el fichero kubeconfig del nodo master del grupo X al del grupo Y con:

```
scp .kube/config linux@192.168.124.1Y0:kubeconfig-grupoX
```

  * Incorporar al .cube/config, las secciones cluster y user del otro grupo, modificando nombres para evitar conflictos
  * Crear una entrada context que relacione el cluster y el user recien incorporados
  * Verificar que funciona cambiando de contexto:

```
kubectl config use-context NOMBRE_CONTEXTO_CREADO
kubectl get pod
```

  * Volver al contexto original

```
kubectl config use-context kubernetes-admin@kubernetes
```

Y a partir de ahora ¡No usar el nuevo contexto para hacerle la puñeta al otro grupo! Mejor borrarlo para evitar "accidentes" ;)

