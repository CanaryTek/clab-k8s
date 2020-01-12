#!/bin/bash

YAML="
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: new-rs
  labels:
    app: test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: nginx
        image: nginxXX
"

echo "$YAML" | kubectl apply -f -

