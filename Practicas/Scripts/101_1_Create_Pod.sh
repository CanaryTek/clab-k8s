#!/bin/bash

YAML="
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: multi
  name: multi-container
spec:
  containers:
  - image: nginx
    name: nginx
  - image: redisx
    name: redis
"

echo "$YAML" | kubectl apply -f -

