#!/bin/bash
# Cleanup script for Question 6 - cert-manager Issuer/Certificate
set -uo pipefail
echo "Cleaning up Question 6: cert-manager..."

kubectl delete certificate internal-tls -n cert-demo --ignore-not-found
kubectl delete secret internal-tls-secret -n cert-demo --ignore-not-found
kubectl delete clusterissuer selfsigned-issuer --ignore-not-found
kubectl delete namespace cert-demo --ignore-not-found

echo "Removing cert-manager itself (CRDs + controller + namespace)..."
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml --ignore-not-found 2>/dev/null || true

echo "[OK] Question 6 cleanup complete"
