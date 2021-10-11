# Monitorizacion

**OJO! Estas prácticas estan obsoletas. No hacerlas**

## Metrics server

  * Clone repo

```
git clone https://github.com/kubernetes-sigs/metrics-server.git
```

  * Actualmente hay un problema en metrics-server, descrito en https://github.com/kubernetes-sigs/metrics-server/issues/131
  * Para resolverlo, aplicar el siguiente parche. **OJO!** Esta configuración es insegura, no esta recomendada para produccion

```
diff --git a/deploy/1.8+/metrics-server-deployment.yaml b/deploy/1.8+/metrics-server-deployment.yaml
index e4bfeaf..14561e2 100644
--- a/deploy/1.8+/metrics-server-deployment.yaml
+++ b/deploy/1.8+/metrics-server-deployment.yaml
@@ -33,6 +33,8 @@ spec:
         args:
           - --cert-dir=/tmp
           - --secure-port=4443
+          - --kubelet-insecure-tls
+          - --kubelet-preferred-address-types=InternalIP
         ports:
         - name: main-port
           containerPort: 4443
```

  * Aplicar

```
kubectl apply -f metrics-server/deploy/1.8+
```

  * Tras unos minutos, deberia funcionar "kubectl top"

```
kubectl top nodes
kubectl top pods
```

## Dashboard

**OJO!!** Esta configuracion es insegura, no utilizar en un cluster de produccion

  * Descargamos el fichero YAML de definicion
```
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
```

## FIXME! Antiguo
#```
#wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc2/aio/deploy/recommended.yaml 
#```
#
#  * Aplicamos parche para:
#    * Usar servicio LoadBalancer para acceder al dashboard desde fuera del cluster
#    * Modificar autenticacion para actual como "cluster-admin" sin hacer login
#
#```
#cat > recommended.yaml.patch <<END
#--- recommended.yaml.orig	2020-01-29 18:25:33.810922956 +0000
#+++ recommended.yaml	2020-01-29 18:20:15.523953070 +0000
#@@ -37,6 +37,7 @@
#   name: kubernetes-dashboard
#   namespace: kubernetes-dashboard
# spec:
#+  type: LoadBalancer
#   ports:
#     - port: 443
#       targetPort: 8443
#@@ -159,7 +160,7 @@
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: ClusterRole
#-  name: kubernetes-dashboard
#+  name: cluster-admin
# subjects:
#   - kind: ServiceAccount
#     name: kubernetes-dashboard
#@@ -195,6 +196,7 @@
#           args:
#             - --auto-generate-certificates
#             - --namespace=kubernetes-dashboard
#+            - --enable-skip-login
#             # Uncomment the following line to manually specify Kubernetes API server Host
#             # If not specified, Dashboard will attempt to auto discover the API server and connect
#             # to it. Uncomment only if the default does not work.
#END
#patch < recommended.yaml.patch
#```

  * Aplicamos fichero de definicion

```
kubectl apply -f recommended.yaml
```

  * Ver ip del servicio y conectarse con el navegador



