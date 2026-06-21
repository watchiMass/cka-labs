#!/bin/bash
# Validation script for Question 3 - Broken kubelet Repair
# NOTE: Intended to run on worker-node-1 itself (or via SSH wrapper) for
# the systemd checks, and from the control plane for the node-status check.
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
echo " Validating Question 3: Broken kubelet"
echo "==========================================="

# 1. kubelet drop-in points at the correct kubeconfig file
check "Drop-in references valid kubeconfig path (kubelet.conf)" \
  bash -c 'grep -q -- "--kubeconfig=/etc/kubernetes/kubelet.conf" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf'

# 2. The referenced kubeconfig file actually exists
check "Referenced kubeconfig file exists on disk" \
  bash -c '[[ -f /etc/kubernetes/kubelet.conf ]]'

# 3. kubelet service is active
check "kubelet systemd service is active (running)" \
  bash -c 'systemctl is-active --quiet kubelet'

# 4. kubelet service is enabled at boot
check "kubelet systemd service is enabled" \
  bash -c 'systemctl is-enabled --quiet kubelet'

# 5. Node reports Ready from control plane (requires kubectl context)
check "Node worker-node-1 is Ready (from control plane)" \
  bash -c '
    STATUS=$(kubectl get node worker-node-1 -o jsonpath="{.status.conditions[?(@.type==\"Ready\")].status}" 2>/dev/null)
    [[ "$STATUS" == "True" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
