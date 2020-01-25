#!/bin/bash

sudo sed -i'' 's/server.crt/server-cert.pem/' /etc/kubernetes/manifests/etcd.yaml
