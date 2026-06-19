#!/bin/bash
# Validation script for Question 3 - Node Scheduling Troubleshooting
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
echo " Validating Question 3: Node Scheduling"
echo "============================================"
echo ""
echo "--- Task 1: Node restored ---"

check "No worker node is in SchedulingDisabled state" \
  bash -c '
    COUNT=$(kubectl get nodes --no-headers | grep -v "control-plane\|master" | grep "SchedulingDisabled" | wc -l)
    [[ "$COUNT" -eq 0 ]]
  '

check "No worker node has the maintenance taint" \
  bash -c '
    COUNT=$(kubectl get nodes -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
count = 0
for node in data[\"items\"]:
    roles = node[\"metadata\"].get(\"labels\", {})
    is_worker = \"node-role.kubernetes.io/control-plane\" not in roles and \"node-role.kubernetes.io/master\" not in roles
    if is_worker:
        taints = node[\"spec\"].get(\"taints\", [])
        for t in taints:
            if t.get(\"key\") == \"maintenance\":
                count += 1
print(count)
" 2>/dev/null)
    [[ "$COUNT" -eq 0 ]]
  '

check "critical-app deployment has 3 desired replicas" \
  bash -c '
    R=$(kubectl get deployment critical-app -n q3-scheduling -o jsonpath="{.spec.replicas}" 2>/dev/null)
    [[ "$R" == "3" ]]
  '

check "critical-app deployment has 3 ready replicas" \
  bash -c '
    R=$(kubectl get deployment critical-app -n q3-scheduling -o jsonpath="{.status.readyReplicas}" 2>/dev/null)
    [[ "$R" == "3" ]]
  '

echo ""
echo "--- Task 2: gpu-workload pod scheduled ---"

check "Pod 'gpu-workload' exists in namespace q3-scheduling" \
  bash -c 'kubectl get pod gpu-workload -n q3-scheduling >/dev/null 2>&1'

check "Pod 'gpu-workload' is Running" \
  bash -c '
    PHASE=$(kubectl get pod gpu-workload -n q3-scheduling -o jsonpath="{.status.phase}" 2>/dev/null)
    [[ "$PHASE" == "Running" ]]
  '

check "Pod 'gpu-workload' has no nodeSelector" \
  bash -c '
    NS=$(kubectl get pod gpu-workload -n q3-scheduling -o jsonpath="{.spec.nodeSelector}" 2>/dev/null)
    [[ -z "$NS" ]]
  '

echo ""
echo "============================================"
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
echo "============================================"

exit $FAIL
