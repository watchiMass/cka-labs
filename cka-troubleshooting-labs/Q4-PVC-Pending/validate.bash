#!/bin/bash
# Validation script for Question 4 - PVC Pending Troubleshooting
set -uo pipefail

PASS=0
FAIL=0
TOTAL=0

check() {
  local description="$1"
  shift
  TOTAL=$((TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    echo "  PASS: $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $description"
    FAIL=$((FAIL + 1))
  fi
}

echo "============================================"
echo " Validating Question 4: PVC Pending"
echo "============================================"
echo ""
echo "--- Task 1: database-pvc / database-pod ---"

check "PVC 'database-pvc' exists in namespace q4-storage" \
  bash -c 'kubectl get pvc database-pvc -n q4-storage >/dev/null 2>&1'

check "PVC 'database-pvc' is Bound" \
  bash -c '
    STATUS=$(kubectl get pvc database-pvc -n q4-storage -o jsonpath="{.status.phase}" 2>/dev/null)
    [[ "$STATUS" == "Bound" ]]
  '

check "PVC 'database-pvc' uses a valid StorageClass (not ultra-fast-nvme)" \
  bash -c '
    SC=$(kubectl get pvc database-pvc -n q4-storage -o jsonpath="{.spec.storageClassName}" 2>/dev/null)
    [[ "$SC" != "ultra-fast-nvme" ]] && [[ -n "$SC" ]]
  '

check "PVC 'database-pvc' still requests 1Gi" \
  bash -c '
    SIZE=$(kubectl get pvc database-pvc -n q4-storage -o jsonpath="{.spec.resources.requests.storage}" 2>/dev/null)
    [[ "$SIZE" == "1Gi" ]]
  '

check "Pod 'database-pod' is Running" \
  bash -c '
    PHASE=$(kubectl get pod database-pod -n q4-storage -o jsonpath="{.status.phase}" 2>/dev/null)
    [[ "$PHASE" == "Running" ]]
  '

echo ""
echo "--- Task 2: shared-pvc / shared-app ---"

check "PVC 'shared-pvc' exists in namespace q4-storage" \
  bash -c 'kubectl get pvc shared-pvc -n q4-storage >/dev/null 2>&1'

check "PVC 'shared-pvc' is Bound" \
  bash -c '
    STATUS=$(kubectl get pvc shared-pvc -n q4-storage -o jsonpath="{.status.phase}" 2>/dev/null)
    [[ "$STATUS" == "Bound" ]]
  '

check "PVC 'shared-pvc' does not use ReadWriteMany" \
  bash -c '
    AM=$(kubectl get pvc shared-pvc -n q4-storage -o jsonpath="{.spec.accessModes[0]}" 2>/dev/null)
    [[ "$AM" != "ReadWriteMany" ]]
  '

check "Deployment 'shared-app' has at least 1 ready replica" \
  bash -c '
    READY=$(kubectl get deployment shared-app -n q4-storage -o jsonpath="{.status.readyReplicas}" 2>/dev/null)
    [[ "${READY:-0}" -ge 1 ]]
  '

echo ""
echo "============================================"
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
echo "============================================"

exit $FAIL
