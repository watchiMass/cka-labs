#!/bin/bash
# Validation script for Question 2 - HA Control Plane Join
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
echo " Validating Question 2: HA Control Plane"
echo "==========================================="

# 1. cp-node-2 exists as a node
check "Node 'cp-node-2' is registered in the cluster" \
  kubectl get node cp-node-2

# 2. cp-node-2 has the control-plane role label
check "cp-node-2 has control-plane role label" \
  bash -c '
    kubectl get node cp-node-2 --show-labels 2>/dev/null | grep -q "node-role.kubernetes.io/control-plane"
  '

# 3. cp-node-2 is Ready
check "cp-node-2 status is Ready" \
  bash -c '
    STATUS=$(kubectl get node cp-node-2 -o jsonpath="{.status.conditions[?(@.type==\"Ready\")].status}" 2>/dev/null)
    [[ "$STATUS" == "True" ]]
  '

# 4. There are now at least 2 control-plane nodes total
check "At least 2 control-plane nodes in the cluster" \
  bash -c '
    COUNT=$(kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers 2>/dev/null | wc -l)
    [[ $COUNT -ge 2 ]]
  '

# 5. etcd static pod is running on cp-node-2 (stacked topology)
check "etcd static pod running on cp-node-2" \
  bash -c '
    kubectl get pods -n kube-system -l component=etcd --field-selector spec.nodeName=cp-node-2 2>/dev/null | grep -q etcd
  '

# 6. kube-apiserver static pod is running on cp-node-2
check "kube-apiserver static pod running on cp-node-2" \
  bash -c '
    kubectl get pods -n kube-system -l component=kube-apiserver --field-selector spec.nodeName=cp-node-2 2>/dev/null | grep -q kube-apiserver
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
