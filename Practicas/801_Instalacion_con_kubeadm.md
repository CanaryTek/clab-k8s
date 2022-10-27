# Despliegue de cluster k8s

Para mas informacion

https://kubernetes.io/docs/setup/independent/install-kubeadm/

  * Partimos de 3 maquinas con Ubuntu 20.04
    * Pueden ser máquinas virtuales en VMWare, HyperV, Qemu/KVM, VirtualBox, etc
    * Config red estatica (luego adaptaremos en cada maquina)
    * usuario/clave: linux/linux
  * Cambiar sudoers para que no pida clave

```
%sudo   ALL=(ALL:ALL) NOPASSWD:ALL
```

  * Crear par de claves ssh y configurar acceso a las 3 máquinas
  * Preparar /etc/hosts (Adaptar las IP)

```
192.168.124.110 master01
192.168.124.111 node01
192.168.124.112 node02
```

## Preparacion

  * Desactivar swap (editar /etc/fstab y reiniciar o swapoff -a)

```bash
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo swapoff -a; cat /etc/fstab | grep -v swap | sudo tee /etc/fstab" ; done
```

  * Verificar que ninguna maquina tiene activado swap

```bash
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "free" ; done
```

  * Cargar modulos del kernel

```bash
cat > containerd-modules.conf <<EOF
overlay
br_netfilter
EOF
for h in master01 node0{1,2}; do echo "*** $h"; cat containerd-modules.conf | ssh linux@$h "sudo tee /etc/modules-load.d/containerd.conf" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo modprobe overlay; sudo modprobe br_netfilter" ; done
```

  * Configurar systctl

```bash
cat > kubernetes-sysctl.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
for h in master01 node0{1,2}; do echo "*** $h"; cat kubernetes-sysctl.conf | ssh linux@$h "sudo tee /etc/sysctl.d/kubernetes.conf" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo sysctl --system" ; done
```

  * Instalar runtime containerd (k8s 1.23 no tiene soporte de docker)

```bash
for h in master01 node0{1,2}; do echo "*** $h"; ssh linux@$h "sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh linux@$h "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh linux@$h 'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"' ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh linux@$h 'sudo apt update; sudo apt install -y containerd.io' ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh linux@$h 'sudo mkdir -p /etc/containerd; containerd config default | sudo tee /etc/containerd/config.toml' ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh linux@$h 'sudo systemctl restart containerd; sudo systemctl enable containerd; systemctl status  containerd' ; done
```

## Instalar paquetes k8s

  * Instalar repos

```bash
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-get install -y apt-transport-https curl" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-add-repository 'deb http://apt.kubernetes.io/ kubernetes-xenial main'"; done
```

  * Instalar kubeadm

```bash
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-get install -y kubelet=1.23.13-00 kubeadm=1.23.13-00 kubectl=1.23.13-00" ; done
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
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

  * Comprobamos nodos, ya deberian aparecer los nodos en estado Ready

```
kubectl get nodes
```

  * Comprobamos pods de sistema

```
kubectl -n kube-system get pod -o wide
```
