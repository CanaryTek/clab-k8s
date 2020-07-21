# Helm Charts

Vamos a usar la version 3, que no utiliza el componente Tiller instalado en el cluster (y que suponia un riesgo de seguridad)

## Instalacion de la utilidad helm

  * Descargamos y desempaquetamos

```
wget https://get.helm.sh/helm-v3.2.2-linux-amd64.tar.gz
tar xvzf helm-v3.2.2-linux-amd64.tar.gz
```

  * Instalamos (p.ej. en /usr/local/bin)

```
sudo cp linux-amd64/helm /usr/local/bin/
sudo chmod 755 /usr/local/bin/helm
```

