# Resource Limits

Vamos a crear 2 Pods con "problemas" de recursos, y los resolveremos

Antes de empezar esta practica, eliminar todos los Pods que se esten ejecutando en el cluster

## Resolver problema en Pod

  * Crear Pod "mem-requester"

```bash
cat > mem-requester.yaml << END
apiVersion: v1
kind: Pod
metadata:
  name: mem-requester
spec:
  containers:
  - image: polinux/stress
    name: mem-requester
    command:
      - stress
      - --vm
      - "1"
      - --vm-bytes
      - 10M
      - --vm-hang
      - "1"
    resources:
      limits:
        memory: 5Gi
      requests:
        memory: 5Gi
END
kubectl apply -f mem-requester.yaml
```

  * ¿En que estado esta? ¿Por que?
  * Resolverlo (puede ser necesario redefinirlo)

## Resolver otro problema

  * Crear Pod "mem-user"

```bash
cat > mem-user.yaml << END
apiVersion: v1
kind: Pod
metadata:
  name: mem-user
spec:
  containers:
  - image: polinux/stress
    name: mem-user
    command:
      - stress
      - --vm
      - "1"
      - --vm-bytes
      - 15M
      - --vm-hang
      - "1"
    resources:
      limits:
        memory: 10Mi
      requests:
        memory: 5Mi
END
kubectl apply -f mem-user.yaml
```

  * ¿En que estado esta? ¿Por que?
  * Resolverlo (puede ser necesario redefinirlo)

<details>
 <summary>Pista</summary>
Comprobar límite de memoria necesaria
</details>           

