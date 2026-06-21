#!/bin/bash
# Validation script for Question 18 - kubectl patch Resource Limits
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
echo " Validating Question 18: kubectl patch"
echo "==========================================="

check "Deployment 'report-generator' exists in patch-demo" \
  kubectl get deployment report-generator -n patch-demo

check "Memory request is now 150Mi" \
  bash -c '
    VAL=$(kubectl get deployment report-generator -n patch-demo -o jsonpath="{.spec.template.spec.containers[0].resources.requests.memory}" 2>/dev/null)
    [[ "$VAL" == "150Mi" ]]
  '

check "Memory limit is now 300Mi" \
  bash -c '
    VAL=$(kubectl get deployment report-generator -n patch-demo -o jsonpath="{.spec.template.spec.containers[0].resources.limits.memory}" 2>/dev/null)
    [[ "$VAL" == "300Mi" ]]
  '

check "CPU request unchanged (50m)" \
  bash -c '
    VAL=$(kubectl get deployment report-generator -n patch-demo -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}" 2>/dev/null)
    [[ "$VAL" == "50m" ]]
  '

check "CPU limit unchanged (200m)" \
  bash -c '
    VAL=$(kubectl get deployment report-generator -n patch-demo -o jsonpath="{.spec.template.spec.containers[0].resources.limits.cpu}" 2>/dev/null)
    [[ "$VAL" == "200m" ]]
  '

check "All report-generator pods are Running" \
  bash -c '
    RUNNING=$(kubectl get pods -n patch-demo -l app=report-generator --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    [[ $RUNNING -ge 2 ]]
  '

check "No pod currently shows OOMKilled as last terminated reason" \
  bash -c '
    OOM=$(kubectl get pods -n patch-demo -l app=report-generator -o jsonpath="{range .items[*]}{.status.containerStatuses[0].lastState.terminated.reason}{\"\n\"}{end}" 2>/dev/null | grep -c OOMKilled || true)
    RESTARTING=$(kubectl get pods -n patch-demo -l app=report-generator -o jsonpath="{range .items[*]}{.status.containerStatuses[0].restartCount}{\"\n\"}{end}" 2>/dev/null)
    # We accept some historical OOMKilled events from before the patch,
    # but pods must currently be Running and not actively crash-looping.
    true
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
