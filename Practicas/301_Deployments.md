# Deployments

## Deploy con estrategia recreate

  * Creamos un deployment con estartegia recreate

```bash
cat > recreate.yaml <<END
apiVersion: apps/v1
kind: Deployment
metadata:
  name: recreate
spec:
  replicas: 4
  selector:
    matchLabels:
      name: recreate
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        name: recreate
    spec:
      containers:
      - image: nginx
        name: nginx
        env:
        - name: VERSION
          value: "1.1"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 1
END
kubectl apply -f recreate.yaml
```

  * Ver deployments y replicasets
    * ¿Cuantos replicasets hay?

  * Editar el fichero y modificar la variable version de 1.1 a 1.2 y aplicar

```bash
kubectl apply -f recreate.yaml
```

  * ¿Se ha producido corte del servicio? ¿Por qué?
  * Ver historico de eventos del deploy

  * Ver replicasets
    * ¿Cuantos hay?
    * ¿Que valor tiene la variable VERSION en el replicaset activo?
    * ¿Que valor tiene la variable VERSION en el replicaset inactivo (con 0 pods)?

## Deploy con rollingupdate

  * Creamos un deployment con estrategia rollingupdate

```bash
cat > rolling.yaml <<END
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling
spec:
  replicas: 4
  selector:
    matchLabels:
      name: rolling
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
  template:
    metadata:
      labels:
        name: rolling
    spec:
      containers:
      - image: nginx
        name: nginx
        env:
        - name: VERSION
          value: "1.2"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 1
END
kubectl apply -f rolling.yaml
```

  * Ver deployments y replicasets
    * ¿Cuantos replicasets hay?

  * Editar el fichero y modificar la variable version de 1.1 a 1.2 y aplicar

```bash
kubectl apply -f recreate.yaml
```

  * ¿Se ha producido corte del servicio? ¿Por qué?
  * Ver historico de eventos del deploy
    * ¿Que diferencia hay con el anterior (estrategia rercreate)?

  * Ver replicasets
    * ¿Cuantos hay?
    * ¿Que valor tiene la variable VERSION en el replicaset activo?
    * ¿Que valor tiene la variable VERSION en el replicaset inactivo (con 0 pods)?

  * Eliminar el deployment rolling
  * Editar el fichero para cambiar "maxSurge" y "maxUnavailable" al 50%
  * Repetir todos los pasos anteriores
    * ¿Que diferencias ha habido con el caso anterior (al 25%)?
    * ¿Cual ha sido más rápido?
    * ¿Cual tiene mas "riesgo"?

## Rollback

  * Ver detalles de un Pod cualquiera del deploy
    * ¿Que valor tiene la variable VERSION?
  * Ver estado de los replicaset
  * Hacer rollback del deploy

  * Ver detalles de un Pod cualquiera del deploy
    * ¿Que valor tiene la variable VERSION?
  * ¿Como se ha hecho el rollback? (pista: ¿cual es el replicaset activo?)

## Otras

  * Rgistro de cambios (opcion --record)
  * Rollout history y status
