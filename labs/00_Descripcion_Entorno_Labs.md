# Labs de practicas para cursos k8s en CloudLab

## Caracteristicas

  * Lab montado con Ubuntu 18.04
  * Kubernetes montado con kubeadm

## Redes

  * Lab1
    * master01: 192.168.124.110
    * node01: 192.168.124.111
    * node02: 192.168.124.112
    * rango LB: 192.168.124.40-192.168.124.49
  * Lab2
    * master01: 192.168.124.120
    * node01: 192.168.124.121
    * node02: 192.168.124.122
    * rango LB: 192.168.124.50-192.168.124.59
  * Lab3
    * master01: 192.168.124.130
    * node01: 192.168.124.131
    * node02: 192.168.124.132
    * rango LB: 192.168.124.60-192.168.124.69
  * Lab4
    * master01: 192.168.124.140
    * node01: 192.168.124.141
    * node02: 192.168.124.142
    * rango LB: 192.168.124.70-192.168.124.79
  * Lab5
    * master01: 192.168.124.150
    * node01: 192.168.124.151
    * node02: 192.168.124.152
    * rango LB: 192.168.124.80-192.168.124.89
  * Lab6
    * master01: 192.168.124.160
    * node01: 192.168.124.161
    * node02: 192.168.124.162
    * rango LB: 192.168.124.90-192.168.124.99

## Preparacion maquinas

Instalamos una maquina desde CD y el resto copiamos el disco y cambiamos nombre e ip

### Preparacion Lab1

#### Preparacion de k8s1.master01

  * Instalar una maquina desde CD
    * Teclado español
    * Config red estatica (luego adaptaremos en cada maquina)
    * usuario/clave: linux/linux
  * Cambiar sudoers para que no pida clave

```
%sudo	ALL=(ALL:ALL) NOPASSWD:ALL
```

  * Crear par de claves ssh y configurar acceso a la propia maquina (asi al clonar ya tenemos la clave)
  * Preparar /etc/hosts

```
192.168.124.110 master01
192.168.124.111 node01
192.168.124.112 node02
```

#### Preparacion de los nodos k8s1.node0{1,2}

  * Copiar el disco del master a las VM de los nodos y arrancarlas

  * Cambiar nombre de los nodos

```
hostnamectl set-hostname node0X
```

  * Cambiar config de red en /etc/netplan/50-cloud-init.yaml

  * Reiniciar nodos

#### Verificar Lab1

  * Probar ping a node01 y node02
  * Probar ssh y sudo a node01 y node02

```
for h in node0{1,2}; do echo "*** $h"; ssh -t linux@$h "sudo hostname" ; done
```

#### Crear snapshot del lab

  * Creamos el snapshot inicial del lab

```
btrfs sub snap -r vm snapshots/00_nodes_installed
```

### Preparar resto de labs

  * Copiar ficheros del lab

```
scp lab.yml Rakefile nuc1:/srv/labs/k8s2/
```

  * Editar el fichero lab.yml y cambiar el prefijo del lab y las macs (las macs deben ser unicas)

  * Inicializar maquinas

```
rake init_vms
```

  * Parar las maquinas creadas

```
rake destroy_vms
```

  * Crear subvolumen vm en destino

```
rm -rvf vm
btrfs sub create vm
```

  * Copiar discos desde lab1

```
# Copiar a maquina remota manteniendo sparse files
tar -Szcf - . | ssh nuc2 'sudo tar -C /srv/labs/k8s3/vm -zvxf -'
```

  * Renombrar los subdirectorios de vm al nombre del lab
  * Arrancamos maquinas:
    * Cambiamos las IP
    * Cambiamos el /etc/hosts

  * Paramos maquinas
  * Creamos snapshot inicial
