#!/bin/bash
# Validation script for Question 13 - Default-Deny NetworkPolicy
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
echo " Validating Question 13: Default-Deny NetworkPolicy"
echo "==========================================="

check "NetworkPolicy 'default-deny-all' exists in secure-zone" \
  kubectl get networkpolicy default-deny-all -n secure-zone

check "default-deny-all selects all pods (empty podSelector)" \
  bash -c '
    SEL=$(kubectl get networkpolicy default-deny-all -n secure-zone -o jsonpath="{.spec.podSelector}" 2>/dev/null)
    [[ "$SEL" == "{}" ]]
  '

check "default-deny-all has no ingress rules defined" \
  bash -c '
    RULES=$(kubectl get networkpolicy default-deny-all -n secure-zone -o jsonpath="{.spec.ingress}" 2>/dev/null)
    [[ -z "$RULES" ]]
  '

check "NetworkPolicy 'allow-from-trusted' exists in secure-zone" \
  kubectl get networkpolicy allow-from-trusted -n secure-zone

check "allow-from-trusted selects app=secure-app pods" \
  bash -c '
    SEL=$(kubectl get networkpolicy allow-from-trusted -n secure-zone -o jsonpath="{.spec.podSelector.matchLabels.app}" 2>/dev/null)
    [[ "$SEL" == "secure-app" ]]
  '

check "allow-from-trusted allows ingress from namespaces labeled access=allowed" \
  bash -c '
    kubectl get networkpolicy allow-from-trusted -n secure-zone -o json 2>/dev/null | grep -q "\"access\": \"allowed\""
  '

check "allow-from-trusted restricts traffic to TCP port 80" \
  bash -c '
    PORT=$(kubectl get networkpolicy allow-from-trusted -n secure-zone -o jsonpath="{.spec.ingress[0].ports[0].port}" 2>/dev/null)
    [[ "$PORT" == "80" ]]
  '

check "Functional: trusted-clients pod CAN reach secure-app" \
  bash -c '
    kubectl exec -n trusted-clients deploy/client -- wget -qO- --timeout=5 http://secure-app.secure-zone.svc.cluster.local
  '

check "Functional: untrusted-clients pod CANNOT reach secure-app" \
  bash -c '
    ! kubectl exec -n untrusted-clients deploy/client -- wget -qO- --timeout=5 http://secure-app.secure-zone.svc.cluster.local
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
