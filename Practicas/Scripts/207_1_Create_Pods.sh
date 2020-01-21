#!/bin/bash

YAML="
apiVersion: v1
kind: Pod
metadata:
  name: static-pod001
spec:
  containers:
    - name: nginx
      image: nginx
"

ssh node01 "sudo mkdir /etc/para_complicarlo >/dev/null 2>&1"
ssh node01 "test -f /var/lib/kubelet/config.yaml.bck || sudo cp /var/lib/kubelet/config.yaml{,.bck}"
ssh node01 "sed 's/kubernetes\/manifests/para_complicarlo/' < /var/lib/kubelet/config.yaml.bck | sudo tee /var/lib/kubelet/config.yaml >/dev/null && sudo systemctl restart kubelet"

echo "$YAML" | ssh node01 "cat - | sudo tee /etc/para_complicarlo/pod.yaml >/dev/null"

