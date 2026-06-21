#!/bin/bash
# Cleanup script for Question 16 - NodePort & Readiness Probe
set -uo pipefail
echo "Cleaning up Question 16: NodePort & Readiness Probe..."

kubectl delete namespace nodeport-demo --ignore-not-found

echo "[OK] Question 16 cleanup complete"
