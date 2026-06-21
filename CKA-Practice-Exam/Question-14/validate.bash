#!/bin/bash
# Validation script for Question 14 - StorageClass & Volume Expansion
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

echo "==========================================="
echo " Validating Question 14: StorageClass & Expansion"
echo "==========================================="

check "StorageClass 'expandable-storage' exists" \
  kubectl get storageclass expandable-storage

check "StorageClass allows volume expansion" \
  bash -c '
    VAL=$(kubectl get storageclass expandable-storage -o jsonpath="{.allowVolumeExpansion}" 2>/dev/null)
    [[ "$VAL" == "true" ]]
  '

check "StorageClass reclaimPolicy is Delete" \
  bash -c '
    VAL=$(kubectl get storageclass expandable-storage -o jsonpath="{.reclaimPolicy}" 2>/dev/null)
    [[ "$VAL" == "Delete" ]]
  '

check "StorageClass volumeBindingMode is WaitForFirstConsumer" \
  bash -c '
    VAL=$(kubectl get storageclass expandable-storage -o jsonpath="{.volumeBindingMode}" 2>/dev/null)
    [[ "$VAL" == "WaitForFirstConsumer" ]]
  '

check "PVC 'app-data-claim' exists in storage-demo" \
  kubectl get pvc app-data-claim -n storage-demo

check "PVC uses expandable-storage StorageClass" \
  bash -c '
    SC=$(kubectl get pvc app-data-claim -n storage-demo -o jsonpath="{.spec.storageClassName}" 2>/dev/null)
    [[ "$SC" == "expandable-storage" ]]
  '

check "PVC is Bound" \
  bash -c '
    PHASE=$(kubectl get pvc app-data-claim -n storage-demo -o jsonpath="{.status.phase}" 2>/dev/null)
    [[ "$PHASE" == "Bound" ]]
  '

check "Pod 'storage-test' exists and mounts app-data-claim" \
  bash -c '
    CLAIM=$(kubectl get pod storage-test -n storage-demo -o jsonpath="{.spec.volumes[0].persistentVolumeClaim.claimName}" 2>/dev/null)
    [[ "$CLAIM" == "app-data-claim" ]]
  '

check "Pod 'storage-test' is Running" \
  bash -c '
    PHASE=$(kubectl get pod storage-test -n storage-demo -o jsonpath="{.status.phase}" 2>/dev/null)
    [[ "$PHASE" == "Running" ]]
  '

check "PVC has been expanded to 2Gi (requested size)" \
  bash -c '
    REQ=$(kubectl get pvc app-data-claim -n storage-demo -o jsonpath="{.spec.resources.requests.storage}" 2>/dev/null)
    [[ "$REQ" == "2Gi" ]]
  '

check "PVC actual capacity reflects 2Gi" \
  bash -c '
    CAP=$(kubectl get pvc app-data-claim -n storage-demo -o jsonpath="{.status.capacity.storage}" 2>/dev/null)
    [[ "$CAP" == "2Gi" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
