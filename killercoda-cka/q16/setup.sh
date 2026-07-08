#!/bin/bash
set -e

mkdir -p /opt/course/16

echo "Setup complete. This exercise assumes a kubeadm-based cluster where"
echo "CoreDNS runs as a Deployment in kube-system with its config in ConfigMap 'coredns'."
kubectl -n kube-system get configmap coredns -o yaml || echo "WARN: coredns ConfigMap not found - check your cluster setup"
