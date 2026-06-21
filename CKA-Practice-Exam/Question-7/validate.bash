#!/bin/bash
# Validation script for Question 7 - PriorityClass & Preemption
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
echo " Validating Question 7: PriorityClass"
echo "==========================================="

check "PriorityClass 'low-priority' exists with value 100" \
  bash -c '
    VAL=$(kubectl get priorityclass low-priority -o jsonpath="{.value}" 2>/dev/null)
    [[ "$VAL" == "100" ]]
  '

check "PriorityClass 'high-priority-critical' exists with value 1000000" \
  bash -c '
    VAL=$(kubectl get priorityclass high-priority-critical -o jsonpath="{.value}" 2>/dev/null)
    [[ "$VAL" == "1000000" ]]
  '

check "high-priority-critical uses PreemptLowerPriority policy" \
  bash -c '
    POL=$(kubectl get priorityclass high-priority-critical -o jsonpath="{.preemptionPolicy}" 2>/dev/null)
    [[ "$POL" == "PreemptLowerPriority" ]]
  '

check "filler Deployment pods use low-priority PriorityClass" \
  bash -c '
    PC=$(kubectl get deployment filler -n priority-demo -o jsonpath="{.spec.template.spec.priorityClassName}" 2>/dev/null)
    [[ "$PC" == "low-priority" ]]
  '

check "Pod 'critical-task' exists in priority-demo" \
  kubectl get pod critical-task -n priority-demo

check "critical-task uses high-priority-critical PriorityClass" \
  bash -c '
    PC=$(kubectl get pod critical-task -n priority-demo -o jsonpath="{.spec.priorityClassName}" 2>/dev/null)
    [[ "$PC" == "high-priority-critical" ]]
  '

check "critical-task pod is Running" \
  bash -c '
    PHASE=$(kubectl get pod critical-task -n priority-demo -o jsonpath="{.status.phase}" 2>/dev/null)
    [[ "$PHASE" == "Running" ]]
  '

check "At least one filler pod was preempted (fewer than 4 filler pods running, or Preempted event present)" \
  bash -c '
    RUNNING_FILLER=$(kubectl get pods -n priority-demo -l app=filler --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    EVENT=$(kubectl get events -n priority-demo 2>/dev/null | grep -ci preempt || true)
    [[ $RUNNING_FILLER -lt 4 || $EVENT -gt 0 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
