# RBAC

## Interpretar configuración

  * ¿Que mecanismos de autorización usa el entorno de Lab?
  * ¿Quantos roles existen en todos los namespaces?
  * ¿Que que tipo de recursos tiene acceso el role weave-net? ¿Que acciones puede ejecutar sobre esos recursos?

## Crear Role y RoleBinding

  * Crear un Role "developer" que pueda listar y crear Pods en el namespace default. (Pista: kubectl create role)

  * Crear un RoleBinding para asignar el Role "developer" al usuario "dev-user1". (Pista kubectl create rolebinding)

  * Comprobar que el usuario puede listar Pods

```
kubectl auth can-i list pods --as dev-user1
```

  * Listar los pods (como usuario dev-user1)

```
kubectl get pod --as dev-user1
```

## Resolver problema

  * Como usuario dev-user1, ver detalles de un pod

```
kubectl describe pod UN_POD_CUALQUIERA --as dev-user1
```

  * ¿Funciona? ¿Por qué?
  * Hacer los cambios necesarios para que funcione (que dev-user1 pueda ver detalles de los pods)
