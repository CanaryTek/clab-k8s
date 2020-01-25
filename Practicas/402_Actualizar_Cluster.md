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

  * Verificar plan de actualizacion

```
sudo kubeadm upgrade plan
```

  * Verificar la version disponible en apt

```
sudo apt-cache policy kubeadm
```

  * Actualizar kubeadm a la version mas nueva disponible

```
sudo apt-get upgrade kubeadm=1.17.1-00
```

  * Actualizar master a la version mas nueva disponible

```
sudo kubeadm upgrade apply v1.17.1
```

  * Verificar que durante el proceso no perdemos servicio a la app web

  * En nuestro caso no es necesario actualizar kubelet porque al actualizar kubeadm desde paquete, el kubelet de la misma version era una dependencia

## Actualizar nodos worker

Hacer esto para cada nodo

  * Vaciar el nodo (en el master)

```
kubectl drain node01
```

  * Actualizar kubeadm

```
sudo apt-get upgrade kubeadm=1.17.1-00
```

  * Actualizar configuracion de kubelet

```
sudo kubeadm upgrade node --kubelet-version v1.17.1
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

