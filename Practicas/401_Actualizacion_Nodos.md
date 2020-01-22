# Actualizacion Nodos

## Despliegue app

  * Desplegar un entorno complejo (webapp + servicio)

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

## Forzar fallo de un nodo

  * Durante estas operaciones, mantener el navegador abierto y recargar la página periódicamente
  * Tambien tener una sesion SSH en el master y ejecutar "kubectl describe svc webapp-color", fijandose en los endpoints

  * Forzar reinicio de node01

```
ssh node01 sudo reboot
```

  * ¿La aplicacion deja de responder en el navegador?
  * ¿Que pasa con los endpoints del servicio?

  * Una vez que node01 vuelve a funcionar, ¿donde se ejecutan los Pods?

## Hacer reinicio "limpio" de un nodo

  * Durante estas operaciones, mantener el navegador abierto y recargar la página periódicamente

  * Vaciar el nodo01

  * ¿Cuantos Pods hay y donde se estan ejecutando?
  * ¿Ha habido corte de servicio?

  * Ver nodos

  * ¿Como aparece node01?

  * Reiniciar nodo01

  * ¿Si ejecutamos un nuevo Pod se ejecutará en node01? ¿Por qué?

  * Marcar nodo01 como disponible

  * ¿Los Pods vuelven al node01? ¿Por qué? ¿Que habría que hacer para que vuelvan?

## Parada de nodos con Pods independientes

  * Definir un Pod independiente

```
kubectl run nginx --image nginx --generator run-pod/v1
```

  * Verificar que responde: "curl http://IP_DEL_POD"

  * ¿En que nodo se esta ejecutando?
  * Vacia el nodo donde se esta ejecutando el Pod "nginx"
  * ¿Que ha pasado con el Pod "nginx"? ¿Por que?
  * Reiniciar el nodo anterior
  * *El Pod sigue respondiendo a "curl"?
  * Cuando vuelva a estar online, marcarlo como disponible
  * ¿El Pod "nginx" esta ejecutandose? ¿Por qué?

## Parada del nodo master

  * Reiniciar el nodo master
  * Mientras se reinicia, recargar el Navegador en la IP del servicio de la primera practica
  * ¿Se pierde el servicio?
