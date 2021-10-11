# Setup AzureDisk CSI

  * You need the azure.json file correctly setup in all nodes, as defined in previous Section (Setup Azure Cloud Controller)

  * Install AzureDisk CSI driver

```
curl -skSL https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/install-driver.sh | bash -s master --
```

  * Wait until the driver pods are running

```
kubectl -n kube-system get pod -o wide --watch -l app=csi-azuredisk-controller
```

  * Create StorageClass

```
kubectl create -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/storageclass-azuredisk-csi.yaml
```

  * Now you can create a PVC with storageClass "disk.csi.azure.com" like the following

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: managed-csi
```
