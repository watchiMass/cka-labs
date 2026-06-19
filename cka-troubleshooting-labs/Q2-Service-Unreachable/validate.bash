#!/bin/bash
# Validation script for Question 2 - Service Unreachable
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
echo " Validating Question 2: Service Unreachable"
echo "============================================"
echo ""

check "Service 'web-service' exists in namespace q2-service" \
  bash -c 'kubectl get svc web-service -n q2-service >/dev/null 2>&1'

check "Service 'web-service' has at least one endpoint" \
  bash -c '
    EP=$(kubectl get endpoints web-service -n q2-service -o jsonpath="{.subsets[0].addresses[0].ip}" 2>/dev/null)
    [[ -n "$EP" ]]
  '

check "Service selector matches pod label tier=frontend" \
  bash -c '
    TIER=$(kubectl get svc web-service -n q2-service -o jsonpath="{.spec.selector.tier}" 2>/dev/null)
    [[ "$TIER" == "frontend" ]]
  '

check "Service targetPort is 80" \
  bash -c '
    PORT=$(kubectl get svc web-service -n q2-service -o jsonpath="{.spec.ports[0].targetPort}" 2>/dev/null)
    [[ "$PORT" == "80" ]]
  '

check "web-app deployment has 2 ready replicas" \
  bash -c '
    READY=$(kubectl get deployment web-app -n q2-service -o jsonpath="{.status.readyReplicas}" 2>/dev/null)
    [[ "$READY" == "2" ]]
  '

check "debug-pod can reach web-service via HTTP (curl returns 200)" \
  bash -c '
    STATUS=$(kubectl exec -n q2-service debug-pod -- curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://web-service 2>/dev/null)
    [[ "$STATUS" == "200" ]]
  '

echo ""
echo "============================================"
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
echo "============================================"

exit $FAIL
