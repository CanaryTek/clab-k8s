# Backup y Restore etcd

## Despliegue de app

  * Si el cluster esta vacio, desplegamos una app para comprobar que no perdemos servicio

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: webapp-color
  name: webapp-color
spec:
  replicas: 4
  selector:
    matchLabels:
      run: webapp-color
  template:
    metadata:
      labels:
        run: webapp-color
    spec:
      containers:
      - image: kukoarmas/webapp-color
        name: webapp-color
        env:
          - name: APP_COLOR
            value: green
---
apiVersion: v1
kind: Service
metadata:
  labels:
    run: webapp-color
  name: webapp-color
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    run: webapp-color
  type: LoadBalancer
```

  * Conectar con el navegador a la IP del servicio creado
    * ¿Funciona?

## Backup de etcd

  * ¿Que tipo de Pod es el de etcd? ¿Donde podemos ver su definición?

  * Verificamos la version de etcd que estamos ejecutando (aparece en los logs)

```
kubectl -n kube-system logs etcd-master01
```

  * Tambien lo podemos ver en la imagen del fichero manifest del Pod

  * Necesitamos usar los certificados para validarnos al etcd, los miramos en el manifest del Pod

```
sudo cat /etc/kubernetes/manifests/etcd.yaml
```

  * Necesitaremos los parametros: endpoints, cacert, cert y key

  * Ademas, es importante mirar que directorios del host se montan en el Pod, para que cuando hagamos el snapshot, el backup lo tengamos en el sistema de ficheros del host. En el manifest vemos que "/var/lib/etcd" del host se monta en "/var/lib/etcd" del Pod. Por tanto, debemos volcar nuestro fichero snapshot dentro de "/var/lib/etcd"

  * Necesitaremos ejecutar lo siguiente para hacer un backup

```
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /var/lib/etcd/backup-01.db
```

  * Pero en el master no tenemos el ciente etcdctl porque lo ejecutamos en un Pod, tenemos que ejecutarlo en el Pod "etcd-master01"

  * Podems conectarnos al Pod con el siguiente comando, y ejecutar el anterior

```
kubectl -n kube-system exec -ti etcd-master01 sh
```

  * O podemos hacerlo todo de una vez

```
kubectl -n kube-system exec -ti etcd-master01 -- sh -c "ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /var/lib/etcd/backup-01.db"
```

  * Verificamos que tenemos el backup en el filesystem del master01

```
sudo ls -l /var/lib/etcd
```

  * Verificamos el backup (en el Pod)

```
kubectl -n kube-system exec -ti etcd-master01 -- sh -c "ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot status -w table /var/lib/etcd/backup-01.db"
```

## Hacemos cambios

Para verificar el impacto de recuperar un snapshot de etcd, vamos a generar cambios en el cluster. Para que el estado no sea el mismo que cuando hicimos el snapshot

  * Borramos el deployment webapp-color

```
kubectl delete deploy webapp-color
```

  * Creamos un nuevo Pod

```
kubectl run nginx --image nginx
```

## Restauramos backup

  * El primer paso para la restauracion es parar kube-apiserver para evitar que siga haciendo cambios. Puesto que se ejecuta como "static Pod", la manera de pararlo es eliminar su fichero manifest. Lo movemos al directorio actual

```
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml .
```

  * Verificar que el Pod de kube-apiserver ya no esta funcionando

```
kubectl -n kube-system get pod
```

  * ¿Que esta pasando?

  * Localizamos el contenedor donde se esta ejecutando el etcd

```
sudo docker ps | grep etcd
```

  * Nos conectamos a ese contenedor docker

```
sudo docker exec -ti ID_CONTENEDOR sh
```

  * Recuperamos el snapshot indicando parametros del nuevo cluster. Como directorio de recuperacion indicamos uno debajo de /var/lib/etc para que este mapeado al filesystem del host (en este caso /var/lib/etcd/recover)

```
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key --data-dir=/var/lib/etcd/recover --initial-cluster-token=etcd-cluster-1 --initial-cluster="master01=http://localhost:2380" --name master01 snapshot restore /var/lib/etcd/backup-01.db
```

  * Ahora necesitamos cambiar el manifest del Pod etcd para usar el nuevo "initial-cluster-token" y cambiando el parametro data-dir
  * Una vez editado el fichero, y puesto que ha cambiado, kubelet matara el contenedor antiguo de etcd y arrancara uno nuevo con la nueva configuracion.

  * Localizamos el nuevo contenedor etcd

```
sudo docker ps | grep etcd
```

  * Comprobamos logs para ver que ha arrancado correctamente y con los nuevos parametros

```
sudo docker logs -f ID_CONTENEDOR
```

  * Podemos conectarnos y comprobar estado del cluster

```
sudo docker exec -ti ID_CONTENEDOR sh -c "ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list"
```

  * Si todo esta correcto, volvemos a arrancar el kube-apiserver devolviendo el fichero manifest a /etc/kubernetes/manifests

```
sudo mv kube-apiserver.yaml /etc/kubernetes/manifests/
```

  * Ver si ya tenemos control del cluster

```
kubectl get pod
```

  * ¿Que ha pasado con el deployment que habiamos borrado?
  * ¿Que ha pasado con el Pod nginx? (buscarlo en los worker)
  * ¿Sigue funcionando la app web?

  * Reiniciar lo nodos worker
  * ¿Cual es el estado final? ¿Funciona ahora la app?

## Jugar con etcd

En el lab, etcd se ejecuta en un contenedor, para ejecutar el cliente etcdctl debemos hacerlo dentro de ese contenedor. Para facilitar el trabajo, podemos definir un alias:

```
alias ketcdctl="kubectl exec etcd-master01 -n kube-system -- etcdctl --cacert /etc/kubernetes/pki/etcd/ca.crt --key /etc/kubernetes/pki/etcd/server.key --cert /etc/kubernetes/pki/etcd/server.crt"
```

Listamos toda la informacion de ETCD


```
ketcdctl get / --prefix --keys-only
```

Consultamos los nodos


```
ketcdctl get /registry/minions --prefix -w json | json_pp  | less
```

