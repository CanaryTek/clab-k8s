# Setup Azure Cloud controller

  * Config azure.json to all nodes

```
for h in master01 node0{1,2}; do echo "*** $h"; cat azure.json | ssh linux@$h "sudo tee /etc/kubernetes/azure.json" ; done
```

  * Setup kubelet in all nodes

```
for h in master01 node0{1,2}; do echo "*** $h"; cat kubelet | ssh linux@$h "sudo tee /etc/default/kubelet" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh linux@$h "sudo systemctl restart kubelet" ; done
```

  * Setup static pods for azure-cloud-controller and change kube.controller-manager config

```
sudo cp ${HOME}/.kube/config /var/lib/kubelet/kubeconfig
sudo cp cloud-controller-manager.yaml /etc/kubernetes/manifests
```

  * Create pod and service and make sure it gets a public IP and is available

```
kubectl run nginx --image nginx
kubectl expose pod nginx --port 80 --type LoadBalancer
```

