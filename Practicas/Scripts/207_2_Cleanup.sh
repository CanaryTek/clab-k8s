#!/bin/bash

ssh node01 "sudo cp /var/lib/kubelet/config.yaml{.bck,} && sudo systemctl restart kubelet"

