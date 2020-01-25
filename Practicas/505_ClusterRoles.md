# ClusterRoles

## Interpretar configuración

  * ¿Cuantos clusterroles existen en todos los namespaces? (¿tiene sentido añadir "en todos los namespaces"?)
  * ¿Cuantos clusterrolebindings existen en el cluster?

  * ¿En que namespace esta el clusterrole cluster-admin?

  * ¿A que usuarios o grupos esta asociado el Role cluster-admin? (Pista: hay un ClusterRoleBinding que se llama igual)
  * ¿Donde se puede definir la pertenencia a grupos? (Pista: ver practica 502)
  * ¿Que permisos tiene el Role cluster-admin?

## Crear ClusterRole y ClusterRoleBinding

  * Crear un Role "node-admin" que pueda listar los nodos. (Pista: kubectl create clusterrole)

  * Crear un RoleBinding para asignar el Role "node-admin" al usuario "node-user1". (Pista kubectl create clusterrolebinding)

  * Comprobar que el usuario puede listar nodos

```
kubectl auth can-i list nodes --as node-user1
```

  * Listar los nodos (como usuario node-user1)

```
kubectl get node --as node-user1
```

## Ampliar permisos

  * Como usuario node-user1, ver detalles de un nodo

```
kubectl describe node node01 --as node-user1
```

  * ¿Funciona? ¿Por qué?
  * Ampliar permiso para que puede hacer cualquier operacion sobre nodos

