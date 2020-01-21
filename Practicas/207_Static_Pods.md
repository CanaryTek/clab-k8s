# Static Pods

## Consultar informacion

  * ¿Cuantos Static Pods hay en el cluster? (en todos los namespaces)
  * ¿En que nodo se ejecutan? 
  * ¿En que directorio estan las definiciones de los Static Pods?
  * ¿Cuantos ficheros de definicion hay en el master? ¿Que son?

## Crear un static pod

  * Crear un static pod en el master (nombre: static-busybox, image: busybox, command: "sleep 1000")
  * ¿Tenemos que definir Tolerations para los Taints del master? ¿Por que?
  * Editar el Pod para usar la imagen busybox:1.28.4
  * Borra el Pod

## Borrar un Pod estatico

  * Crea un Pod estatico ejecutando el script

```bash
sh Practicas/Scripts/207_1_Create_Pods.sh
```

  * Localizalo y borralo

  * Dejar todo como estaba

```bash
sh Practicas/Scripts/207_2_Cleanup.sh
```
