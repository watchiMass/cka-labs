#!/bin/bash
# Validation script for Question 9 - Container Runtime Misconfiguration
# Intended to run on worker-node-2 (for local checks) plus from the
# control plane (for the node-status check).
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
echo " Validating Question 9: Container Runtime"
echo "==========================================="

check "kubelet drop-in references the correct containerd socket" \
  bash -c 'grep -q -- "--container-runtime-endpoint=unix:///run/containerd/containerd.sock" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf'

check "containerd.sock actually exists at the referenced path" \
  bash -c '[[ -S /run/containerd/containerd.sock ]]'

check "/etc/crictl.yaml configured with correct runtime-endpoint" \
  bash -c 'grep -q "unix:///run/containerd/containerd.sock" /etc/crictl.yaml'

check "kubelet systemd service is active" \
  bash -c 'systemctl is-active --quiet kubelet'

check "crictl ps succeeds using default endpoint (no --runtime-endpoint needed)" \
  bash -c 'crictl ps'

check "Node worker-node-2 is Ready (from control plane)" \
  bash -c '
    STATUS=$(kubectl get node worker-node-2 -o jsonpath="{.status.conditions[?(@.type==\"Ready\")].status}" 2>/dev/null)
    [[ "$STATUS" == "True" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
