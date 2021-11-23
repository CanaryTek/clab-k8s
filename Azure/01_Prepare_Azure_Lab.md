# Create Lab in Azure

## Create Azure resources (with CLI)

  * Create Resource Group ```RG_LabX```

```
az group create --name RG_LabX --location westeurope
```

  * Create vnet and subnet

```
az network vnet create -g RG_LabX -n VNet_Lab --address-prefix 172.16.0.0/16 --subnet-name Lab --subnet-prefix 172.16.11.0/24
```

  * Create Availability Set

```
az vm availability-set create -n AS_Lab -g RG_LabX
```

  * Create Network Security Group

```
az network nsg create -g RG_LabX -n NSG_LB
```

  * Create the 3 nodes
    * Change ssh-key-value to the key you want to use to access nodes using SSH
    * Change public-ip-address-dns-name for unique name. The master will be available in this name, appending "westeurope.cloudapp.azure.com"

```
# Master01
$ az vm create -n master01 -g RG_LabX --image ubuntults --vnet-name VNet_Lab --subnet Lab --private-ip-address 172.16.11.11 --public-ip-address-dns-name ctk-master01-ip-pub --admin-username linux --ssh-key-value .ssh/kuko-rsa.pub --size Standard_B2ms --storage-sku StandardSSD_LRS --nsg "" --availability-set AS_Lab
{- Finished ..
  "fqdns": "ctk-master01-ip-pub.westeurope.cloudapp.azure.com",
  "id": "/subscriptions/XXXXXXXXXXXXX/resourceGroups/RG_LabX/providers/Microsoft.Compute/virtualMachines/master01",
  "location": "westeurope",
  "macAddress": "00-0D-3A-47-49-E0",
  "powerState": "VM running",
  "privateIpAddress": "172.16.11.11",
  "publicIpAddress": "20.107.34.134",
  "resourceGroup": "RG_LabX",
  "zones": ""
}
# Node01
$ az vm create -n node01 -g RG_LabX --image ubuntults --vnet-name VNet_Lab --subnet Lab --private-ip-address 172.16.11.21 --public-ip-address "" --admin-username linux --ssh-key-value .ssh/kuko-rsa.pub --size Standard_B2ms --storage-sku StandardSSD_LRS --nsg "" --availability-set AS_Lab
{- Finished ..
  "fqdns": "",
  "id": "/subscriptions/XXXXXXXXXXXXX/resourceGroups/RG_LabX/providers/Microsoft.Compute/virtualMachines/node01",
  "location": "westeurope",
  "macAddress": "00-0D-3A-AC-72-C4",
  "powerState": "VM running",
  "privateIpAddress": "172.16.11.21",
  "publicIpAddress": "",
  "resourceGroup": "RG_LabX",
  "zones": ""
}
# Node02
$ az vm create -n node02 -g RG_LabX --image ubuntults --vnet-name VNet_Lab --subnet Lab --private-ip-address 172.16.11.22 --public-ip-address "" --admin-username linux --ssh-key-value .ssh/kuko-rsa.pub --size Standard_B2ms --storage-sku StandardSSD_LRS --nsg "" --availability-set AS_Lab
{- Finished ..
  "fqdns": "",
  "id": "/subscriptions/XXXXXXXXXXXXX/resourceGroups/RG_LabX/providers/Microsoft.Compute/virtualMachines/node02",
  "location": "westeurope",
  "macAddress": "00-0D-3A-AF-19-AB",
  "powerState": "VM running",
  "privateIpAddress": "172.16.11.22",
  "publicIpAddress": "",
  "resourceGroup": "RG_LabX",
  "zones": ""
}
```

  * With the previous example, we should be able to connect to the master with

```
ssh linux@ctk-master01-ip-pub.westeurope.cloudapp.azure.com
```


  * Create Service Principal
    * Get the RG "scope" from the previous commands output (up to ```RG_LabX```)

```
$ az ad sp create-for-rbac --name "sp-labX.canarytek.com" --role="Contributor" --scopes="/subscriptions/XXXXXXXXXXXXX/resourceGroups/RG_LabX" -o json
Changing "sp-labX.canarytek.com" to a valid URI of "http://sp-labX.canarytek.com", which is the required format used for service principal names
Creating 'Contributor' role assignment under scope '/subscriptions/XXXXXXXXXXXXX/resourceGroups/RG_LabX'
The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
{
  "appId": "XXXXXXXXXXXXX",
  "displayName": "sp-labX.canarytek.com",
  "name": "http://sp-labX.canarytek.com",
  "password": "XXX~XXXXX~XXX-XXX",
  "tenant": "XXXXXXXXXXXXX"
}
```

  * Take note of the AppId and password. They will be used in the azure.json file later

## Prepare nodes

Once the Lab is created on Azure

  * Setup /etc/hosts

```
# K8s
172.16.11.11 master01
172.16.11.21 node01
172.16.11.22 node02
```

  * Create ssh keypair (no passwords)

```
ssh-keygen
```

  * Copy ssh keys to all nodes

```
for h in master01 node0{1,2}; do echo "*** $h"; ssh-copy-id -i .ssh/id_rsa.pub $h; done
```

  * Make sure we have access (connect with no agent forward)

```
for h in master01 node0{1,2}; do echo "*** $h"; ssh $h hostname; done
```

  * Copy /etc/hosts to all hosts

```
for h in master01 node0{1,2}; do echo "*** $h"; cat /etc/hosts | ssh $h sudo tee /etc/hosts; done
```

  * Check

```
for h in master01 node0{1,2}; do echo "*** $h"; ssh $h sudo cat /etc/hosts; done
```

## Install k8s

Follow a typical k8s install with kubeadm

```
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-get install -y apt-transport-https curl" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-add-repository 'deb http://apt.kubernetes.io/ kubernetes-xenial main'"; done

for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-get install -y docker.io; sudo systemctl enable docker" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt install -y kubelet=1.21.5-00 kubeadm=1.21.5-00 kubectl=1.21.5-00"; done

sudo kubeadm config images pull
sudo kubeadm init
```

  * And join worker nodes...

