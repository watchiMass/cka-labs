#!/bin/bash
# Cleanup script for Question 1 - Pod CrashLoopBackOff Troubleshooting
set -uo pipefail

echo "Cleaning up Question 1: Pod CrashLoopBackOff..."
kubectl delete namespace q1-crashloop --ignore-not-found
echo "[OK] Question 1 cleanup complete"
