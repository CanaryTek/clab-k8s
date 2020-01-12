# MetalLB

MetalLB es una implementacion de Servicios tipo LoadBalancer para instalaciones de Kubernetes locales

Basicamente lo que hace es asignar una IP publica a cada servicio de tipo LoadBalancer. Para que funcione debemos decirle el rango de direcciones IP disponibles para estos servicios

## Instalacion

  * Instalamos MetalLB

```bash
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml
```

  * Verificamos que se esta ejecutando correctamente

```bash
linux@master01:~$ kubectl get pod -n metallb-system
NAME                          READY   STATUS    RESTARTS   AGE
controller-65895b47d4-l7qj6   1/1     Running   0          5m32s
speaker-d5sm5                 1/1     Running   0          5m32s
speaker-jdsk8                 1/1     Running   0          5m32s
speaker-mns8n                 1/1     Running   0          5m32s
```

  * Aun no puede funcionar porque no le hemos dicho el rango de IP disponible
  * Indicarlo a traves de un ConfigMap (concepto que veremos mas adelante)
    * ¡Ojo! Cada entorno tiene un rango diferente

```bash
cat > metallb-conf.yaml << END
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.124.40-192.168.124.49
END
kubectl apply -f metallb-conf.yaml
```

  * Una vez creado, el servicio nginx-alb creado en la practica de servicios deberia obtener una IP

```bash
linux@master01:~$ kubectl get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1       <none>           443/TCP        21d
nginx        ClusterIP      10.96.106.163   <none>           80/TCP         35m
nginx-ext    NodePort       10.96.17.65     <none>           80:30080/TCP   24m
nginx-lb     LoadBalancer   10.96.232.141   192.168.124.40   80:32675/TCP   9m52s
```

  * Conectar desde fuera del cluster a la IP publica con navegador

