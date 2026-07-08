#!/bin/bash
set -e

mkdir -p /opt/course/5
cp -r "$(dirname "$0")/api-gateway" /opt/course/5/api-gateway

kubectl create namespace api-gateway-staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace api-gateway-prod --dry-run=client -o yaml | kubectl apply -f -

kubectl kustomize /opt/course/5/api-gateway/staging | kubectl apply -f -
kubectl kustomize /opt/course/5/api-gateway/prod | kubectl apply -f -

# Metrics server needed for HPA to work fully (best-effort install, not required to pass validation)
kubectl get deployment metrics-server -n kube-system &>/dev/null || \
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml 2>/dev/null || true

echo "Setup complete."
