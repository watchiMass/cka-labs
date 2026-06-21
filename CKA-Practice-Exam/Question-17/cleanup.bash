#!/bin/bash
# Cleanup script for Question 17 - TLS Cert Mismatch
set -uo pipefail
echo "Cleaning up Question 17: TLS Cert Mismatch..."

kubectl delete namespace tls-demo --ignore-not-found

echo "[OK] Question 17 cleanup complete"
