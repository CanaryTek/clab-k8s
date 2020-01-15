# Node Affinity

## Node Affinity simple

  * Etiquetar un nodo
  * Crear deployment de 4 replicas
  * Assignar nodeAffinity para que el deployment anterior se ejecute solo en el nodo etiquetado

## Taints/Tolerations y Node Affinity

  * Configurar lo necesario para conseguir el siguiente escenario
    * Tener un Pod "red", con imagen nginx, que se ejecute exclusivamente en el nodo01
    * Que cualquier otro Pod (sin necesidad de definir nada en el Pod, se ejecute en el nodo02, o cualquier nodo adicional si aumentamos el cluster

