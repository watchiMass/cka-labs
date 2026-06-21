#!/bin/bash
# Validation script for Question 8 - Complex NetworkPolicy
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
echo " Validating Question 8: Complex NetworkPolicy"
echo "==========================================="

check "NetworkPolicy 'api-server-policy' exists in backend" \
  kubectl get networkpolicy api-server-policy -n backend

check "Policy selects pods with app=api-server" \
  bash -c '
    SEL=$(kubectl get networkpolicy api-server-policy -n backend -o jsonpath="{.spec.podSelector.matchLabels.app}" 2>/dev/null)
    [[ "$SEL" == "api-server" ]]
  '

check "Policy has both Ingress and Egress policyTypes" \
  bash -c '
    TYPES=$(kubectl get networkpolicy api-server-policy -n backend -o jsonpath="{.spec.policyTypes[*]}" 2>/dev/null)
    [[ "$TYPES" == *"Ingress"* && "$TYPES" == *"Egress"* ]]
  '

check "Policy has at least 2 ingress rules (port 80 and 9090 separated)" \
  bash -c '
    COUNT=$(kubectl get networkpolicy api-server-policy -n backend -o jsonpath="{.spec.ingress}" 2>/dev/null | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null)
    [[ "$COUNT" -ge 2 ]]
  '

check "Ingress rule allows TCP port 80" \
  bash -c '
    kubectl get networkpolicy api-server-policy -n backend -o json 2>/dev/null | grep -q "\"port\": 80"
  '

check "Ingress rule allows TCP port 9090" \
  bash -c '
    kubectl get networkpolicy api-server-policy -n backend -o json 2>/dev/null | grep -q "\"port\": 9090"
  '

check "Egress rule allows TCP port 443" \
  bash -c '
    kubectl get networkpolicy api-server-policy -n backend -o json 2>/dev/null | grep -q "\"port\": 443"
  '

check "Egress rule allows port 53 (DNS)" \
  bash -c '
    kubectl get networkpolicy api-server-policy -n backend -o json 2>/dev/null | grep -q "\"port\": 53"
  '

check "Functional: frontend pod CAN reach api-server on port 80" \
  bash -c '
    kubectl exec -n frontend deploy/web-client -- wget -qO- --timeout=5 http://api-server.backend.svc.cluster.local:80
  '

check "Functional: monitoring pod CANNOT reach api-server on port 80 (policy enforced)" \
  bash -c '
    ! kubectl exec -n monitoring deploy/metrics-scraper -- wget -qO- --timeout=5 http://api-server.backend.svc.cluster.local:80
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
