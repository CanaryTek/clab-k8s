# Actualizacion Nodos

## Despliegue app

  * Desplegamos la misma app que en la practica anterior. Para comprobar que no perdemos servicio

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: webapp-color
  name: webapp-color
spec:
  replicas: 4
  selector:
    matchLabels:
      run: webapp-color
  template:
    metadata:
      labels:
        run: webapp-color
    spec:
      containers:
      - image: kukoarmas/webapp-color
        name: webapp-color
        env:
          - name: APP_COLOR
            value: green
---
apiVersion: v1
kind: Service
metadata:
  labels:
    run: webapp-color
  name: webapp-color
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    run: webapp-color
  type: LoadBalancer
```

  * ¿Cuantos Pods hay y donde se estan ejecutando?
  * Conectar con el navegador a la IP del servicio creado
    * ¿Funciona?

## Actualizar nodo master

  * Actualizar kubeadm a la ultima version (de paquete)
    * Los labs estan instalados con la version 1.21.5

  * Verificar la version disponible en apt

```
sudo apt list -a kubeadm
```

  * Actualizar kubeadm a la version mas nueva disponible

```
sudo apt install kubeadm=1.24.5-00 kubelet=1.24.5-00
```

  * Verificar plan de actualizacion

```
sudo kubeadm upgrade plan
```

  * Actualizar master a la version mas nueva disponible

```
sudo kubeadm upgrade apply v1.24.5
```

  * Verificar que durante el proceso no perdemos servicio a la app web

  * En nuestro caso no es necesario actualizar kubelet porque al actualizar kubeadm desde paquete, el kubelet de la misma version era una dependencia

  * Verificamos versiones

```
kubectl version
kubectl get node
```

## Actualizar nodos worker

Hacer esto para cada nodo

  * Vaciar el nodo (en el master)

```
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data
```

  * Actualizar kubeadm

```
sudo apt install kubeadm=1.24.5-00 kubelet=1.24.5-00
```

  * Actualizar configuracion de kubelet

```
sudo kubeadm upgrade node
```

  * Reiniciar kubelet

```
sudo systemctl restart kubelet
```

  * Marcar como disponible (en el master)

```
kubectl uncordon node01
```

  * Verificar que se ha actualizado

```
kubectl get node
```

