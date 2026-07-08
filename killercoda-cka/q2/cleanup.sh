#!/bin/bash
helm uninstall cert-manager -n cert-manager 2>/dev/null || true
kubectl delete namespace cert-manager --ignore-not-found=true --wait=false
kubectl delete clusterissuer --all --ignore-not-found=true
kubectl delete crd -l app.kubernetes.io/instance=cert-manager --ignore-not-found=true 2>/dev/null || true
rm -rf /opt/course/2
echo "Cleanup complete"
