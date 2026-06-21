#!/bin/bash
# Validation script for Question 5 - HPA
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
echo " Validating Question 5: HPA"
echo "==========================================="

check "HPA 'cpu-stress-hpa' exists in hpa-demo" \
  kubectl get hpa cpu-stress-hpa -n hpa-demo

check "HPA targets Deployment 'cpu-stress'" \
  bash -c '
    TARGET=$(kubectl get hpa cpu-stress-hpa -n hpa-demo -o jsonpath="{.spec.scaleTargetRef.name}" 2>/dev/null)
    [[ "$TARGET" == "cpu-stress" ]]
  '

check "minReplicas is 1" \
  bash -c '
    MIN=$(kubectl get hpa cpu-stress-hpa -n hpa-demo -o jsonpath="{.spec.minReplicas}" 2>/dev/null)
    [[ "$MIN" == "1" ]]
  '

check "maxReplicas is 6" \
  bash -c '
    MAX=$(kubectl get hpa cpu-stress-hpa -n hpa-demo -o jsonpath="{.spec.maxReplicas}" 2>/dev/null)
    [[ "$MAX" == "6" ]]
  '

check "CPU utilization target is 50%" \
  bash -c '
    TGT=$(kubectl get hpa cpu-stress-hpa -n hpa-demo -o jsonpath="{.spec.metrics[0].resource.target.averageUtilization}" 2>/dev/null)
    [[ "$TGT" == "50" ]]
  '

check "Scale-down stabilization window is 120s" \
  bash -c '
    WIN=$(kubectl get hpa cpu-stress-hpa -n hpa-demo -o jsonpath="{.spec.behavior.scaleDown.stabilizationWindowSeconds}" 2>/dev/null)
    [[ "$WIN" == "120" ]]
  '

check "Scale-up policy adds at most 2 pods per period" \
  bash -c '
    VAL=$(kubectl get hpa cpu-stress-hpa -n hpa-demo -o jsonpath="{.spec.behavior.scaleUp.policies[0].value}" 2>/dev/null)
    [[ "$VAL" == "2" ]]
  '

check "HPA is reporting a real CPU metric (not unknown)" \
  bash -c '
    CURRENT=$(kubectl get hpa cpu-stress-hpa -n hpa-demo -o jsonpath="{.status.currentMetrics[0].resource.current.averageUtilization}" 2>/dev/null)
    [[ -n "$CURRENT" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
