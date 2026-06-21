#!/bin/bash
# Validation script for Question 15 - etcd Disaster Recovery
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
echo " Validating Question 15: etcd Disaster Recovery"
echo "==========================================="

# 1. etcd manifest is back in the watched directory
check "etcd.yaml is present in /etc/kubernetes/manifests" \
  bash -c '[[ -f /etc/kubernetes/manifests/etcd.yaml ]]'

# 2. /var/lib/etcd exists and is non-empty (restored data)
check "/var/lib/etcd exists and contains restored data" \
  bash -c '[[ -d /var/lib/etcd ]] && [[ -n "$(ls -A /var/lib/etcd 2>/dev/null)" ]]'

# 3. etcd static pod container is running
check "etcd container is running (crictl)" \
  bash -c 'crictl ps 2>/dev/null | grep -q etcd'

# 4. API server is reachable
check "API server responds to kubectl get nodes" \
  kubectl get nodes

# 5. Node is Ready
check "Control-plane node is Ready" \
  bash -c '
    STATUS=$(kubectl get nodes -o jsonpath="{.items[0].status.conditions[?(@.type==\"Ready\")].status}" 2>/dev/null)
    [[ "$STATUS" == "True" ]]
  '

# 6. etcd member list returns successfully (cluster healthy)
check "etcd member list succeeds (cluster healthy)" \
  bash -c '
    ETCDCTL_API=3 etcdctl member list \
      --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key
  '

# 7. kube-system pods are running again (proves full cluster recovery)
check "kube-system pods are running" \
  bash -c '
    RUNNING=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | grep -c Running)
    [[ $RUNNING -gt 0 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
