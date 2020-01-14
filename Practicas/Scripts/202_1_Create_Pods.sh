#!/bin/bash

YAML="
apiVersion: v1
kind: Pod
metadata:
  name: app1
  labels:
    app: payroll
    env: dev
    tier: frontend
spec:
  containers:
    - name: nginx
      image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: app2
  labels:
    app: payroll
    env: prod
    tier: frontend
spec:
  containers:
    - name: nginx
      image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: app3
  labels:
    app: crm
    env: dev
    tier: frontend
spec:
  containers:
    - name: nginx
      image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: app4
  labels:
    app: crm
    env: prod
    tier: frontend
spec:
  containers:
    - name: nginx
      image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: bbdd1
  labels:
    app: payroll
    env: dev
    tier: backend
spec:
  containers:
    - name: redis
      image: redis
---
apiVersion: v1
kind: Pod
metadata:
  name: bbdd2
  labels:
    app: payroll
    env: prod
    tier: backend
spec:
  containers:
    - name: redis
      image: redis
---
apiVersion: v1
kind: Pod
metadata:
  name: bbdd3
  labels:
    app: crm
    env: dev
    tier: backend
spec:
  containers:
    - name: redis
      image: redis
---
apiVersion: v1
kind: Pod
metadata:
  name: bbdd4
  labels:
    app: crm
    env: prod
    tier: backend
spec:
  containers:
    - name: redis
      image: redis
"

echo "$YAML" | kubectl apply -f -

