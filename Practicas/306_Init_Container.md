# Pods con initContainer

## Crear Pod con 1 container y 2 initContainer

  * Crear un Pod (Nombre: multi) con los  siguientes contenedores
    * containers
      * Nombre: nginx, image: nginx
    * initContainers
      * Nombre: init1, image: busybox, command: "sleep 10"
      * Nombre: init2, image: busybox, command: "sleep 20"

  * Cuanto tarda en pasar a estado "Running"?

## Crear un Pod nginx e inicializarlo

  * Crear un Pod con un contenedor nginx y un initContainer que inicialice el fichero index.html
  * Pistas:
    * Hay que definir un volumen que monten ambos contenedores
    * Desde el initContainer crear el contenido con "echo 'Hola Mundo' > index.html
    * En el contenedor nginx, montar ese volumen en /usr/share/nginx/html

