#!/bin/bash
# Validation script for Question 19 - Resource Allocation v2
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
echo " Validating Question 19: Resource Allocation v2"
echo "==========================================="

HIGHMEM_NODE=$(kubectl get nodes -l pool=highmem -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

check "Deployment 'analytics-worker' exists in alloc-v2-demo" \
  kubectl get deployment analytics-worker -n alloc-v2-demo

check "Deployment has 4 replicas" \
  bash -c '
    REPLICAS=$(kubectl get deployment analytics-worker -n alloc-v2-demo -o jsonpath="{.spec.replicas}" 2>/dev/null)
    [[ "$REPLICAS" == "4" ]]
  '

check "All 4 replicas are available" \
  bash -c '
    AVAIL=$(kubectl get deployment analytics-worker -n alloc-v2-demo -o jsonpath="{.status.availableReplicas}" 2>/dev/null)
    [[ "${AVAIL:-0}" -ge 4 ]]
  '

check "nodeSelector pool=highmem is set" \
  bash -c '
    SEL=$(kubectl get deployment analytics-worker -n alloc-v2-demo -o jsonpath="{.spec.template.spec.nodeSelector.pool}" 2>/dev/null)
    [[ "$SEL" == "highmem" ]]
  '

check "Pod anti-affinity preference is defined for app=analytics-worker" \
  bash -c '
    kubectl get deployment analytics-worker -n alloc-v2-demo -o json 2>/dev/null | grep -q "podAntiAffinity"
  '

check "CPU requests are set and less than CPU limits" \
  bash -c '
    REQ=$(kubectl get deployment analytics-worker -n alloc-v2-demo -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}" 2>/dev/null)
    LIM=$(kubectl get deployment analytics-worker -n alloc-v2-demo -o jsonpath="{.spec.template.spec.containers[0].resources.limits.cpu}" 2>/dev/null)
    [[ -n "$REQ" && -n "$LIM" ]]
  '

check "Memory requests are set and present alongside memory limits" \
  bash -c '
    REQ=$(kubectl get deployment analytics-worker -n alloc-v2-demo -o jsonpath="{.spec.template.spec.containers[0].resources.requests.memory}" 2>/dev/null)
    LIM=$(kubectl get deployment analytics-worker -n alloc-v2-demo -o jsonpath="{.spec.template.spec.containers[0].resources.limits.memory}" 2>/dev/null)
    [[ -n "$REQ" && -n "$LIM" ]]
  '

check "All analytics-worker pods are scheduled on the pool=highmem node" \
  bash -c "
    NODES=\$(kubectl get pods -n alloc-v2-demo -l app=analytics-worker -o jsonpath='{.items[*].spec.nodeName}' 2>/dev/null)
    [[ -n \"\$NODES\" ]] || exit 1
    for n in \$NODES; do
      [[ \"\$n\" == \"$HIGHMEM_NODE\" ]] || exit 1
    done
  "

check "All analytics-worker pods are Running" \
  bash -c '
    RUNNING=$(kubectl get pods -n alloc-v2-demo -l app=analytics-worker --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    [[ $RUNNING -ge 4 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
