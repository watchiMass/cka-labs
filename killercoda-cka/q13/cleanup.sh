#!/bin/bash
kubectl delete namespace project-r500 --ignore-not-found=true --wait=false
kubectl delete gatewayclass nginx --ignore-not-found=true
kubectl delete -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.5.0/deploy/default/deploy.yaml --ignore-not-found=true 2>/dev/null || true
kubectl delete -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.5.0/deploy/crds.yaml --ignore-not-found=true 2>/dev/null || true
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml --ignore-not-found=true 2>/dev/null || true
rm -rf /opt/course/13
echo "Cleanup complete"
