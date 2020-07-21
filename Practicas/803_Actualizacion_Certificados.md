# Renovacion de certificados

En una instalacion con kubeadm, los certificados se generan con una duracion de 1 año, por lo que será necesario actualizarlos antes de que caduquen

Los certificados de las CA se generan con una duracion de 10 años, con lo que en principio es menos probable que caduquen durante la vida util del cluster

Debido a su diferente criticidad y manejo, se suelen gestionar de forma diferente los certificados de los componentes del plano de control (api, controller-manager, etcd, etc), y los certificados de nodos (kubelet)

## Renovacion de certificados en plano de control

Esta operacion hay que hacerla en el nodo master. En caso de tener una instalacion multi master, habria que hacerlo en todos los nodos master

  * Verificar validez de los certificados

```
sudo kubeadm alpha certs check-expiration
```

  * Renovar todos los certificados

```
sudo kubeadm alpha certs renew all
```

## Renovacion de los certificados de nodos

### Forzar renovacion manual

Una forma "bruta" de forzar la renovacion del certificado de un nodo, es simplemente sacarlo del cluster y volver a añadirlo
En este ejemplo, vamos a hacerlo con el nodo "node01"


**En el master**

  * Vaciamos el nodo

```
kubectl drain --delete-local-data --ignore-daemonsets node01
```

  * Lo eliminamos del cluster

```
kubectl delete node node01
```

  * Si no tenemos documentado el token para unir nodos, generamos uno:

```
kubeadm token create --print-join-command | tee join.txt
```

**En node01**

  * Paramos kubelet

```
systemctl stop kubelet
```

  * Eliminamos datos anteriores (para poder ejecutar el kubeadm join)

```
rm -rf /etc/kubernetes
```

  * Unimos el nodo al cluster con el comando join del apartado anterior

```
kubeadm join 192.168.122.11:6443 --token bl9t71.eb0grh6z2zd2qlc9     --discovery-token-ca-cert-hash sha256:039e97b1fc26f48d3bc2f2bd91cac5279791fea601d32858ef813a1bb277e271
```

  * Verificamos que volvemos a tener el nodo

```
linux@master01:~$ kubectl get node
NAME       STATUS   ROLES    AGE    VERSION
master01   Ready    master   194d   v1.16.3
node01     Ready    <none>   0s     v1.16.3
node02     Ready    <none>   194d   v1.16.3
```

### Configuracion de rotacion de certificados


