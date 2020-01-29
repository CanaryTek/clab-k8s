# Instalacion HA Stacked

Instalaremos 

Servicios en los masters:
  - Keepalived para gestionar la IP de servicio del haproxy
  - HAProxy en los 3 masters como proxy de apiserver

  - etcd en los 3 masters
  - plano de control

## Instalacion de keepalived y haproxy

  * Instalamos los paquetes

```
for h in master0{1,2,3}; do echo "*** $h"; ssh -t linux@$h "sudo apt-get install -y keepalived haproxy" ; done
```

  * Configuramos keepalived para gestionar la IP flotante 192.168.124.170

```
cat > keepalived.conf <<END
global_defs {
   notification_email {
     noc@canarytek.com
   }
}

vrrp_instance KUBE_APISERVER {
    state MASTER
    interface ens3
    virtual_router_id 101
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1234
    }
    virtual_ipaddress {
        192.168.124.170
    }
}
END
for h in master0{1,2,3}; do echo "*** $h"; cat keepalived.conf | ssh linux@$h "sudo tee /etc/keepalived/keepalived.conf" ; done
```

  * Activar y arrancar servicio, y verificar que la IP esta activa en un nodo

```
for h in master0{1,2,3}; do echo "*** $h"; ssh linux@$h "sudo systemctl enable keepalived; sudo systemctl restart keepalived" ; done
for h in master0{1,2,3}; do echo "*** $h"; ssh linux@$h "ip a sh dev ens3" ; done
```

  * Configurar HAProxy

```
cat > haproxy.cfg <<END
listen HAProxy-Statistics
  bind *:80
  mode http
  stats enable
  stats uri /
  stats refresh 60s
  stats show-node
  stats show-legends

frontend k8s-api
  bind *:443
  stats uri /haproxy?stats
  mode tcp
  option tcplog
  default_backend k8s-api

backend k8s-api
  mode tcp
  option tcp-check
  balance roundrobin
  server master01 master01:6443 check
  server master02 master02:6443 check
  server master03 master03:6443 check
END
for h in master0{1,2,3}; do echo "*** $h"; cat haproxy.cfg | ssh linux@$h "sudo tee /etc/haproxy/haproxy.cfg" ; done
```

  * Activar y arrancar servicio

```
for h in master0{1,2,3}; do echo "*** $h"; ssh linux@$h "sudo systemctl enable haproxy; sudo systemctl restart haproxy" ; done
```

## Instalar nodos master

  * Instalar el primer nodo master

```
sudo kubeadm init --control-plane-endpoint "192.168.124.170:443" --pod-network-cidr=10.32.0.0/12 --upload-certs
```

  * Una vez terminado, nos dara los comandos a ejecutar para añadir nodos worker y nodos master. Almacenar ambos comandos en un fichero para usarlos mas adelante

  * Desplegar soporte de red

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

  * Añadirmos los master usando el comando indicado cuando desplegamos el primer nodo. Por ejemplo

```
sudo  kubeadm join 192.168.124.170:443 --token jkruk4.78r1w859m8mulv3a \
    --discovery-token-ca-cert-hash sha256:721a7e491c8462cf3481e41c2a6dcd380db9a4e1e7842ba807ff57d700fa25b8 \
    --control-plane --certificate-key e3875221dcc491339f7523d702d2c42c609b53f727dee56f219d36bd7c3b861c
```
