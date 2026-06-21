#!/bin/bash
# Cleanup script for Question 11 - Gateway API HTTPRoute
set -uo pipefail
echo "Cleaning up Question 11: Gateway API..."

kubectl delete httproute store-route -n gw-demo --ignore-not-found
kubectl delete gateway demo-gateway -n gw-demo --ignore-not-found
kubectl delete namespace gw-demo --ignore-not-found

echo "Leaving Gateway API CRDs installed (shared infra); to remove them too:"
echo "  kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml"

echo "[OK] Question 11 cleanup complete"
