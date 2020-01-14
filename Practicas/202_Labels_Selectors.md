# Labels y Selectors

  * Desplegar varios Pods desde script

  * Ver Pods

  * Los pods se han organizado con labels:
    * env: entorno (dev y prod)
    * tier: capa (frontend, backend)
    * app: aplicacion (payroll, crm)

  * Localizar (mediante consultas "kubectl get pod") lo siguiente:
    * Los Pods que forman la aplicacion "crm"
    * Los Pods que forman la aplicacion "payroll"
    * Los Pods de backend
    * Los Pods de desarrollo (dev)
    * El Pod backend de la aplicacion "crm" de produccion

