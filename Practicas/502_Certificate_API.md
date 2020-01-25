# Certificates API

## Generar una clave y CSR

Tenemos un nuevo miembro del equipo de administradores de nuestro cluster k8s. Necesitamos crearle un certificado para que pueda gestionar la infraestructura con kubectl.
Que cada uno utilice su nombre, en mi caso usare "kuko"

  * Generamos una clave privada RSA de 2048 bits

```
openssl genrsa -out kuko.key 2048
```

  * Generamos el fichero CSR a nombre de "kuko"

```
openssl req -new -key kuko.key -subj "/CN=kuko" -out kuko.csr
```

  * Tras estos pasos, debemos tener un fichero .key con la clave privada, y otro .csr con el CSR

## Crear objeto CSR en k8s

El siguiente paso es crear el ojeto CertificateSigningRequest en kubernetes

  * Crea un fichero YAML partiendo con la siguiente estructura basica

```
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: 
spec:
  groups:
  - system:authenticated
  usages:
  - digital signature
  - key encipherment
  - server auth
  request: CONTENIDO_CSR
```

  * ¡OJO! El contenido del certificado debe estar en base64 y sin saltos de línea (se pueden borrar saltos de linea con "tr -d'\n' ")

  * Una vez creado, consultar los CSR con

```
kubectl get csr
```

  * ¿En que estado esta?

## Aprobar la solicitud

  * Aprobar la solicitud de certificado (kubectl certificate approve)

  * Consultar el estado de los CSR. ¿En que estado esta ahora?

## Denegar una solicitud

  * Repite los pasos anteriores, excepto la aprobación, para crear otro CSR a nombre de "elmalo"
  * Deniega la solicitud. ¿En que estado queda?
  * Borra la solicitud

```
kubectl delete csr elmalo
```

