# Prepare Lab

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

## Instalacion

```
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-get install -y apt-transport-https curl" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-add-repository 'deb http://apt.kubernetes.io/ kubernetes-xenial main'"; done

for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt-get install -y docker.io; sudo systemctl enable docker" ; done
for h in master01 node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo apt install -y kubelet=1.21.5-00 kubeadm=1.21.5-00 kubectl=1.21.5-00"; done

sudo kubeadm config images pull
sudo kubeadm init
```
