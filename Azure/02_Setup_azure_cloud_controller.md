# Setup Azure Cloud controller

  * Create azure.json with cluster credentials

```
{
    "cloud":"AzurePublicCloud",
    "tenantId": "TENANT_ID",
    "aadClientId": "AppId of the service principa created in azure",
    "aadClientSecret": "password of the service principal created in azure",
    "subscriptionId": "SUBSCRIPTION_ID",
    "resourceGroup": "RG_labX",
    "vnetResourceGroup": "RG_labX",
    "location": "westeurope",
    "subnetName": "Lab",
    "vnetName": "VNet_Lab",
    "securityGroupName": "NSG_LB",
    "primaryAvailabilitySetName": "AS_Lab",
    "routeTableName": "routes",
    "cloudProviderBackoff": false,
    "useManagedIdentityExtension": false,
    "useInstanceMetadata": true
}
```

  * Copy to all nodes


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

