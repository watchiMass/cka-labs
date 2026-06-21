#!/bin/bash
# Cleanup script for Question 18 - kubectl patch Resource Limits
set -uo pipefail
echo "Cleaning up Question 18: kubectl patch Resource Limits..."

kubectl delete namespace patch-demo --ignore-not-found

echo "[OK] Question 18 cleanup complete"
