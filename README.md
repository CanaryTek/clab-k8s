# Curso de Introduccion a Kubernetes con CTK CloudLab

En este curso trataremos la temática básica de gestión de cluster kubernetes, al nivel suficiente (espero) para aprobar el examen de certificación de CKA

## Temario

  * Dia 1:
     * [00 Preparacion de los Entornos de Labs](labs/00_Preparacion_Entorno_Labs.md)
     * [01 Descripcion de los Entornos de Labs](labs/01_Descripcion_Entorno_Labs.md)
     * [02 Comandos básicos kubectl](labs/02_Comandos_Basicos.md)
     * [03 Introduccion a Docker](labs/03_Introduccion_Docker.md)
       - Conceptos
       - Comandos basicos
       - Creacion de imagenes
       - Repositorios
       - Command vs entrypoint
     * [10 Conceptos_Basicos Kubernetes](labs/11_Conceptos_Basicos_K8s.md)
     * Practicas
       * Paseo por el entorno
         * Ver nodos
         * Ver Pods
         * Ver namespaces
      * Plano de control
         * Ver pods en kube-system
         * Ver manifests de los pods de control (y configuraciones)
         * Ver procesos con "ps ax"
      * Jugar con etcd
  * Dia 2:
     * [20 Planificador de procesos](labs/20_Planificador_Procesos.md)
     * [30 Logs y monitorizacion](labs/30_Logs_Monitorizacion.md)
        * Instalar dashboard
     * [40 Gestion de ciclo de vida de aplicaciones]()
     * [50 Mantenimiento del cluster]()
     * [60 Seguridad]()
     * [70 Almacenamiento]()
        * PV en NFS
     * [80 Redes]()
        * MetalLB
     * [90 Instalacion de un cluster k8s]()
     * [100 Resolucion de problemas]()

## Practicas

  * Tema 1:
    * [101 Pods](Practicas/101_Pods.md)
    * [102 ReplicaSets](Practicas/102_ReplicaSets.md)
    * [103 Deployments](Practicas/103_Deployements.md)
    * [104 Namespaces](Practicas/104_Namespaces.md)
    * [105 Services](Practicas/105_Services.md)
    * [106 MetalLB](Practicas/106_MetalLB.md)
    * [201 Manual Scheduling](Practicas/201_Manual_Scheduling.md)
    * [202 Labels and Selectors](Practicas/202_Labels_Selectors.md)
    * [203 Taints and Tolerations](Practicas/203_Taints_Tolerations.md)
    * [204](Practicas/204_Node_Affinity.md)
    * [205](Practicas/205_Resource_Limits.md)
    * [206](Practicas/206_DaemonSets.md)
    * [207](Practicas/207_Static_Pods.md)
    * [301](Practicas/301_Deployments.md)
    * [302](Practicas/302_Commands_Args.md)
    * [303](Practicas/303_ConfigMaps.md)
    * [304](Practicas/304_Secrets.md)
    * [305](Practicas/305_Multi_Container.md)
    * [306](Practicas/306_Init_Container.md)
    * [307](Practicas/307_Monitorizacion.md)
    * [401](Practicas/401_Actualizacion_Nodos.md)
    * [402](Practicas/402_Actualizar_Cluster.md)
    * [403](Practicas/403_Backup_etcd.md)
    * [501](Practicas/501_Revisar_Certificados.md)
    * [502](Practicas/502_Certificate_API.md)
    * [503](Practicas/503_KubeConfig.md)
    * [504](Practicas/504_RBAC.md)
    * [505](Practicas/505_ClusterRoles.md)
    * [506](Practicas/506_Security_Context.md)
    * [507](Practicas/507_Network_Policies.md)
    * [601](Practicas/601_Volumes.md)
    * [602](Practicas/602_PV_PVC.md)
    * [603](Practicas/603_CNI_NFS.md)
    * [701](Practicas/701_Service_iptables.md)
    * [702](Practicas/702_DNS_Diagnostico_Red.md)
    * [703](Practicas/703_Ingress.md)
    * [801](Practicas/801_Instalacion_con_kubeadm.md)
    * [802](Practicas/802_Instalacion_HA_kubeadm.md)
