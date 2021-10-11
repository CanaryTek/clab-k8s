# Setup AzureFile CSI

  * You need the azure.json file correctly setup in all nodes, as defined in previous Section (Setup Azure Cloud Controller)

  * Install AzureFile CSI driver

```
curl -skSL https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/v1.7.0/deploy/install-driver.sh | bash -s v1.7.0 --
```

  * Wait until the driver pods are running

```
kubectl -n kube-system get pod -o wide --watch -l app=csi-azurefile-controller
```

  * Create StorageClass

```
kubectl create -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/storageclass-azurefile-csi.yaml
```

  * Now you can create a PVC with storageClass "disk.csi.azure.com" like the following

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: azurefile-csi
```
