#!/bin/bash
# Cleanup script for Question 12 - Ingress with TLS
set -uo pipefail
echo "Cleaning up Question 12: Ingress with TLS..."

kubectl delete namespace ingress-demo --ignore-not-found

echo "[OK] Question 12 cleanup complete"
