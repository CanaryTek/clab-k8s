# Commands and Arguments

## Crear un Pod

  * Crear un Pod con la imagen de busybox que ejecute el comando sleep durante 3000 segundos. Añadir lo que falte a la siguiente definicion

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: busybox-sleeper
  name: busybox-sleeper
spec:
  containers:
  - image: busybox
    name: busybox-sleeper
```

## Corregir errores de definicion

  * Crear el siguiente Pod. Corregir errores si es necesario

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: busybox-sleeper1
  name: busybox-sleeper1
spec:
  containers:
  - image: busybox
    name: busybox-sleeper
    commamd:
    - sleep
    - 1000
```

## Identificar comando en Dockerfile

  * Dado un contenedor creado con el siguiente Dockerfile

```
FROM python:3.6-alpine
RUN pip install flask
COPY . /opt
EXPOSE 8080
WORKDIR /opt
ENTRYPOINT ["python","app.py"]
CMD ["--color","red"]
```

  * ¿Que comando se ejecutara al arrancar?

  * Si creamos un Pod con la siguiente definicion y la imagen creada con el Dockerfile anterior, ¿que comando se ejecutara?

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: app
  name: app
spec:
  containers:
  - image: myapp
    name: myapp
    command: ["--color","green"]
```

  * Si creamos un Pod con la siguiente definicion y la imagen creada con el Dockerfile anterior, ¿que comando se ejecutara?

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: app
  name: app
spec:
  containers:
  - image: myapp
    name: myapp
    args: ["--color","green"]
```

