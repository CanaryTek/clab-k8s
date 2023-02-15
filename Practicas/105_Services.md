# Practicas de Servicios

## Crear Servicio ClusterIP

  * Crear un deploy con nginx de 1 replica

```bash
kubectl create deployment --image=nginx nginx
linux@master01:~$ kubectl create deployment --image=nginx nginx
linux@master01:~$ kubectl get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
nginx-86c57db685-2dlqr   1/1     Running   0          37s   10.46.0.1   node01   <none>           <none>
```

  * Comprobar conectividad a la IP de un Pod con curl (hay que averiguar la IP del POD)

```bash
linux@master01:~$ curl http://10.46.0.1
```

  * Matar el Pod
  * Probar la conectividad otra vez
    * ¿Que ha pasado?
  * Crear un servicio ClusterIP

```bash
# Modo imperativo
kubectl expose deploy nginx --port 80
```

  * Ver servicio

```bash
linux@master01:~$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   21d
nginx        ClusterIP   10.96.106.163   <none>        80/TCP    2m41s
```

  * Acceder con curl a la IP del servicio
  * Matar el Pod
  * Volver a acceder con curl. ¿Funciona?
  * Ver cuantos "Endpoints" hay conectados al servicio
    * ¿Que son?

```bash
linux@master01:~$ kubectl describe svc nginx
Name:              nginx
Namespace:         default
Labels:            app=nginx
Annotations:       <none>
Selector:          app=nginx
Type:              ClusterIP
IP:                10.96.106.163
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.46.0.1:80
Session Affinity:  None
Events:            <none>
```

  * Escalar el deployment a 2 replicas
    * ¿Cuantos endpoints hay conectados ahora al servicio?

  * ¿Podemos acceder a ese servicio desde fuera del cluster? ¿Por que?

## Crear Servicio NodePort

  * Crear servicio de tipo NodePort para el deployment anterior

```bash
cat > service.yaml << END
apiVersion: v1
kind: Service
metadata:
  name: nginx-ext
spec:
  type: NodePort
  ports:
   - port: 80
     targetPort: 80
     nodePort: 30080
  selector:
    app: nginx
END
kubectl apply -f service.yaml
```

  * Ver detalles del servicio

  * Conectarse con curl a la IP ClusterIP

  * Conectar desde fuera del cluster al puerto 30080 de los nodos worker

## Crear Servicio LoadBalance

  * Crear servicio de tipo LoadBalance para el deployment nginx anterior

```bash
cat > servicelb.yaml << END
apiVersion: v1
kind: Service
metadata:
  name: nginx-lb
spec:
  type: LoadBalancer
  ports:
   - port: 80
     targetPort: 80
  selector:
    app: nginx
END
kubectl apply -f servicelb.yaml
```

  * Ver detalles del servicio

```bash
linux@master01:~$ kubectl get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP        21d
nginx        ClusterIP      10.96.106.163   <none>        80/TCP         26m
nginx-ext    NodePort       10.96.17.65     <none>        80:30080/TCP   15m
nginx-lb     LoadBalancer   10.96.232.141   <pending>     80:32675/TCP   7s
```

 * ¿Por que se queda en pending la IP externa?
