#!/bin/bash
# setup-cert-manager.sh
# Question 6 - Services & Networking / CRDs: cert-manager Self-Signed Certificate
set -uo pipefail

echo "Setting up Question 6: cert-manager CRDs..."

kubectl create namespace cert-demo --dry-run=client -o yaml | kubectl apply -f -

echo "Installing cert-manager (CRDs + controller)..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

echo "Waiting for cert-manager deployments to become available (this can take ~60s)..."
kubectl wait --for=condition=Available --timeout=180s \
  deployment/cert-manager -n cert-manager || true
kubectl wait --for=condition=Available --timeout=180s \
  deployment/cert-manager-webhook -n cert-manager || true
kubectl wait --for=condition=Available --timeout=180s \
  deployment/cert-manager-cainjector -n cert-manager || true

echo "[OK] Question 6 lab environment ready"
echo "cert-manager is installed; namespace 'cert-demo' is ready for your Issuer/Certificate."
