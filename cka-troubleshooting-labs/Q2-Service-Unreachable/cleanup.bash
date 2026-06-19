#!/bin/bash
# Cleanup script for Question 2 - Service Unreachable
set -uo pipefail

echo "Cleaning up Question 2: Service Unreachable..."
kubectl delete namespace q2-service --ignore-not-found
echo "[OK] Question 2 cleanup complete"
