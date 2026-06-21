#!/bin/bash
# Validation script for Question 10 - Taints, Tolerations & Affinity
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
echo " Validating Question 10: Taints & Affinity"
echo "==========================================="

GPU_NODE=$(kubectl get nodes -l hardware=gpu -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

check "GPU node still has the dedicated=gpu-workloads:NoSchedule taint" \
  bash -c "kubectl get node \"$GPU_NODE\" -o json 2>/dev/null | grep -q '\"key\": \"dedicated\"'"

check "Deployment 'gpu-workload' exists in scheduling-demo" \
  kubectl get deployment gpu-workload -n scheduling-demo

check "gpu-workload has toleration for dedicated=gpu-workloads:NoSchedule" \
  bash -c '
    KEY=$(kubectl get deployment gpu-workload -n scheduling-demo -o jsonpath="{.spec.template.spec.tolerations[0].key}" 2>/dev/null)
    VAL=$(kubectl get deployment gpu-workload -n scheduling-demo -o jsonpath="{.spec.template.spec.tolerations[0].value}" 2>/dev/null)
    [[ "$KEY" == "dedicated" && "$VAL" == "gpu-workloads" ]]
  '

check "gpu-workload has required node affinity for hardware=gpu" \
  bash -c '
    kubectl get deployment gpu-workload -n scheduling-demo -o json 2>/dev/null | grep -q "\"key\": \"hardware\""
  '

check "All gpu-workload pods are scheduled on the GPU node" \
  bash -c "
    NODES=\$(kubectl get pods -n scheduling-demo -l app=gpu-workload -o jsonpath='{.items[*].spec.nodeName}' 2>/dev/null)
    [[ -n \"\$NODES\" ]] || exit 1
    for n in \$NODES; do
      [[ \"\$n\" == \"$GPU_NODE\" ]] || exit 1
    done
  "

check "No generic-app pods are scheduled on the GPU node" \
  bash -c "
    NODES=\$(kubectl get pods -n scheduling-demo -l app=generic-app -o jsonpath='{.items[*].spec.nodeName}' 2>/dev/null)
    for n in \$NODES; do
      [[ \"\$n\" != \"$GPU_NODE\" ]] || exit 1
    done
  "

check "gpu-workload pods are Running" \
  bash -c '
    RUNNING=$(kubectl get pods -n scheduling-demo -l app=gpu-workload --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    [[ $RUNNING -ge 2 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
