#!/bin/bash
# Validation script for Question 16 - NodePort & Readiness Probe
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
echo " Validating Question 16: NodePort & Readiness"
echo "==========================================="

check "Service 'webapp' is type NodePort on 30080" \
  bash -c '
    TYPE=$(kubectl get svc webapp -n nodeport-demo -o jsonpath="{.spec.type}" 2>/dev/null)
    NP=$(kubectl get svc webapp -n nodeport-demo -o jsonpath="{.spec.ports[0].nodePort}" 2>/dev/null)
    [[ "$TYPE" == "NodePort" && "$NP" == "30080" ]]
  '

check "readinessProbe httpGet path is now '/' (fixed)" \
  bash -c '
    PATH_VAL=$(kubectl get deployment webapp -n nodeport-demo -o jsonpath="{.spec.template.spec.containers[0].readinessProbe.httpGet.path}" 2>/dev/null)
    [[ "$PATH_VAL" == "/" ]]
  '

check "readinessProbe still exists (not removed)" \
  bash -c '
    kubectl get deployment webapp -n nodeport-demo -o jsonpath="{.spec.template.spec.containers[0].readinessProbe}" 2>/dev/null | grep -q "httpGet"
  '

check "All 3 webapp pods are Ready (1/1)" \
  bash -c '
    READY_COUNT=$(kubectl get pods -n nodeport-demo -l app=webapp -o jsonpath="{range .items[*]}{.status.containerStatuses[0].ready}{\"\n\"}{end}" 2>/dev/null | grep -c true)
    [[ $READY_COUNT -ge 3 ]]
  '

check "Service Endpoints has 3 addresses populated" \
  bash -c '
    COUNT=$(kubectl get endpoints webapp -n nodeport-demo -o jsonpath="{.subsets[0].addresses}" 2>/dev/null | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null)
    [[ "$COUNT" -ge 3 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
