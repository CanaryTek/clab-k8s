# Practicas de Namespaces

## Crear Namespace

  * Crear un Namespace "test"
  * Crear pod en ese namespace (nombre: nginx, image: nginx)
  * Borrar el namespace "test"
    * ¿Que pasa con los objetos que habia en el NameSpace?

## Crear Namespace con Quotas

  * Crear Namespace "limited"
  * Limitar numero de pods a 3 (el resto de limites da igual)
  * Definir deployment con 2 replicas
  * Escalar deployment a 4 replicas
    * ¿Que pasa?
  * Modificar quota para poder hacerlo

