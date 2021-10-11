# Despliegue de cluster k8s

Para mas informacion

https://kubernetes.io/docs/setup/independent/install-kubeadm/

## Preparacion

  * Desactivar swap (editar /etc/fstab y reiniciar o swapoff -a)

```bash
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo swapoff -a; cat /etc/fstab | grep -v swap | sudo tee /etc/fstab" ; done
```

  * Verificar que ninguna maquina tiene activado swap

```bash
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "free" ; done
```

  * Instalar repos

```bash
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-get install -y apt-transport-https curl" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-add-repository 'deb http://apt.kubernetes.io/ kubernetes-xenial main'"; done
```

  * Instalar kubeadm

```bash
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-get install -y docker.io kubelet=1.21.5-00 kubeadm=1.21.5-00 kubectl=1.21.5-00; sudo systemctl enable docker" ; done
```

## Inicializar cluster

  * Descargar imagenes (en master)

```
sudo kubeadm config images pull
```

  * Inicializar master

```
sudo kubeadm init --pod-network-cidr=10.32.0.0/12
```

  * Preparar configuracion de kubectl tal como se indica en la salid

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

  * Comprobar nodos (solo aparecera el master01)

```
kubectl get nodes
```

  * Recomendacion: almacenar la sintaxis kubeadm para añadir un nodo
  * De todas formas, si lo perdemos podemos generarlo con

```
kubeadm token create --print-join-command
```

  * Añadir los workers

```
for h in node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo kubeadm join LAS_OPCIONES_MOSTRADAS_PARA_JOIN" ; done
```

  * Comprobar nodos. Deberian aparecer los 3 nodos, pero sin en estado NotReady porque aun no tenemos solucion de red desplegada

```
kubectl get nodes
```

  * Desplegar plugin de red (weavenet)

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

  * Comprobamos nodos, ya deberian aparecer los nodos en estado Ready

```
kubectl get nodes
```

  * COmprobamos pods de systema

```
kubectl -n kube-system get pod -o wide
```
