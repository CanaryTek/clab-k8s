# Labels y Selectors

  * Desplegar varios Pods desde script

```
sh Practicas/Scripts/202_1_Create_Pods.sh
```

  * Ver Pods

  * Los pods se han organizado con labels:
    * env: entorno (dev y prod)
    * tier: capa (frontend, backend)
    * app: aplicacion (payroll, crm)

  * Localizar (mediante consultas "kubectl get pod") lo siguiente:
    * Los Pods que forman la aplicacion "crm"

```bash
kubectl get pod -l app=crm
```

    * Los Pods que forman la aplicacion "payroll"

```bash
kubectl get pod -l app=payroll
```

    * Los Pods de backend

```bash
kubectl get pod -l tier=backend
```

    * Los Pods de desarrollo (dev)

```bash
kubectl get pod -l env=dev
```

    * El Pod backend de la aplicacion "crm" de produccion

```bash
kubectl get pod -l env=prod,app=crm,tier=backend
```

