# Primeros pasos en Kubernetes

En esta seccion vamos a dar los primeros pasos en Kubernetes con el cliente CLI kubectl

## Uso basico

  * Autocompletado. Podemos ponerlo en .bash_profile, .bashrc o similar

```bash
source <(kubectl completion bash)
```

  * Obtener ayuda

```
kubectl help
```

  * Verbos: get, describe, create, delete, apply
    * Se puede pasar como parametro un objeto puntual, un fichero o un directorio completo

  * Ver nodos del cluster

```
kubectl get nodes
kubectk get nodes -owide
```

  * Ver pods

```
kubectl get pods
```

  * Espacios de nombres (ya los veremos con mas detalle)

```
kubectl get pods --all-namespaces
kubectl -n kube-system get pods
```

## Modos de uso: Imperativo y Declarativo

Con kubectl podemos hacer dos tipos de acciones:

  * Imperativas: Cuando le decimos que haga algo
    * create, delete, run, expose, etc
    * Podemos pasar la definicion de objetos por linea de comandos, o especificarlo en fichero
  * Declarativas: Cuando le definimos un estado, y le decimos que lo "aplique". Solo hara lo necesario para llegar al estado deseado
    * apply

  * La siguiente linea crea los objetos definidos en el fichero. Si ya existen, da error

```
kubectl create -f fichero.yaml
```
  * La siguiente linea hace lo necesario para que los objetos existan tal como estan definidos en el fichero. Si ya existen no hace nada, si existen, pero con otra configuracion, los modifica

```
kubectl apply -f fichero.yaml
```

## Algunas combinaciones útiles

  * Volcar a YAML un objeto para modificarlo con apply

```
kubectl get pod mypod -o yaml > fichero.yaml
```

  * Generar YAML desde comando imperativo, o para ver lo que haría el comando (--dry-run indica que no haga nada)

```
kubectl create deploy mydeploy --image nginx --dry-run -o yaml > fichero.yaml
```

## Practica: Un paseo por el entorno de lab

  * Ver la version

```bash
linux@master01:~$ kubectl version 
Client Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.0", GitCommit:"70132b0f130acc0bed193d9ba59dd186f0e634cf", GitTreeState:"clean", BuildDate:"2019-12-07T21:20:10Z", GoVersion:"go1.13.4", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.0", GitCommit:"70132b0f130acc0bed193d9ba59dd186f0e634cf", GitTreeState:"clean", BuildDate:"2019-12-07T21:12:17Z", GoVersion:"go1.13.4", Compiler:"gc", Platform:"linux/amd64"}
```

  * Informacion del cluster

```bash
linux@master01:~$ kubectl cluster-info 
Kubernetes master is running at https://192.168.124.110:6443
KubeDNS is running at https://192.168.124.110:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://192.168.124.110:6443/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

  * Ver nodos

```bash
linux@master01:~$ kubectl get nodes
NAME       STATUS   ROLES    AGE   VERSION
master01   Ready    master   39d   v1.17.0
node01     Ready    <none>   39d   v1.17.0
node02     Ready    <none>   39d   v1.17.0
```

  * Ver pods

```bash
linux@master01:~$ kubectl get pods
No resources found in default namespace.
```

  * Ver pods en todos los namespaces

```bash
linux@master01:~$ kubectl get pods --all-namespaces
NAMESPACE              NAME                                         READY   STATUS    RESTARTS   AGE
ingress-nginx          nginx-ingress-controller-5556bd798f-tqf2j    1/1     Running   0          28h
kube-system            coredns-6955765f44-2l7td                     1/1     Running   1          39d
kube-system            coredns-6955765f44-5246m                     1/1     Running   1          39d
kube-system            etcd-master01                                1/1     Running   1          39d
kube-system            kube-apiserver-master01                      1/1     Running   1          39d
kube-system            kube-controller-manager-master01             1/1     Running   1          39d
kube-system            kube-proxy-2pzxq                             1/1     Running   1          39d
kube-system            kube-proxy-99qhg                             1/1     Running   1          39d
kube-system            kube-proxy-jpzs5                             1/1     Running   1          39d
kube-system            kube-scheduler-master01                      1/1     Running   1          39d
kube-system            metrics-server-789c77976-m7696               1/1     Running   0          25h
kube-system            weave-net-b6wqg                              2/2     Running   3          39d
kube-system            weave-net-k8m8q                              2/2     Running   3          39d
kube-system            weave-net-q7wp7                              2/2     Running   4          39d
kubernetes-dashboard   dashboard-metrics-scraper-7b64584c5c-hcdrj   1/1     Running   0          28h
kubernetes-dashboard   kubernetes-dashboard-7bbff494-nrlvp          1/1     Running   0          28h
metallb-system         controller-65895b47d4-wz8q6                  1/1     Running   0          28h
metallb-system         speaker-9wzrx                                1/1     Running   0          28h
metallb-system         speaker-lq9rz                                1/1     Running   0          28h
metallb-system         speaker-w4h9j                                1/1     Running   0          28h
```

  * Ver namespaces

```bash
linux@master01:~$ kubectl get ns
NAME                   STATUS   AGE
default                Active   39d
ingress-nginx          Active   28h
kube-node-lease        Active   39d
kube-public            Active   39d
kube-system            Active   39d
kubernetes-dashboard   Active   28h
metallb-system         Active   28h
```

  * Ver pods de sistema

```bash
linux@master01:~$ kubectl -n kube-system get pod
NAME                               READY   STATUS    RESTARTS   AGE
coredns-6955765f44-2l7td           1/1     Running   1          39d
coredns-6955765f44-5246m           1/1     Running   1          39d
etcd-master01                      1/1     Running   1          39d
kube-apiserver-master01            1/1     Running   1          39d
kube-controller-manager-master01   1/1     Running   1          39d
kube-proxy-2pzxq                   1/1     Running   1          39d
kube-proxy-99qhg                   1/1     Running   1          39d
kube-proxy-jpzs5                   1/1     Running   1          39d
kube-scheduler-master01            1/1     Running   1          39d
metrics-server-789c77976-m7696     1/1     Running   0          25h
weave-net-b6wqg                    2/2     Running   3          39d
weave-net-k8m8q                    2/2     Running   3          39d
weave-net-q7wp7                    2/2     Running   4          39d
```

## Interactuar con pods

  * Ver logs de un pod

```
kubectl -n kube-system logs -f kube-apiserver-master01
```

  * Ejecutar comando en un Pod (p.ej un shell)

```
kubectl -n kube-system exec -ti kube-apiserver-master01 sh 
```
