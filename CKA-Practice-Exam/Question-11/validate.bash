#!/bin/bash
# Validation script for Question 11 - Gateway API HTTPRoute
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
echo " Validating Question 11: Gateway API"
echo "==========================================="

check "Gateway API CRDs are installed" \
  kubectl get crd gateways.gateway.networking.k8s.io

check "Gateway 'demo-gateway' exists in gw-demo" \
  kubectl get gateway demo-gateway -n gw-demo

check "Gateway uses gatewayClassName demo-gateway-class" \
  bash -c '
    GC=$(kubectl get gateway demo-gateway -n gw-demo -o jsonpath="{.spec.gatewayClassName}" 2>/dev/null)
    [[ "$GC" == "demo-gateway-class" ]]
  '

check "Gateway has an HTTP listener on port 80" \
  bash -c '
    PORT=$(kubectl get gateway demo-gateway -n gw-demo -o jsonpath="{.spec.listeners[0].port}" 2>/dev/null)
    PROTO=$(kubectl get gateway demo-gateway -n gw-demo -o jsonpath="{.spec.listeners[0].protocol}" 2>/dev/null)
    [[ "$PORT" == "80" && "$PROTO" == "HTTP" ]]
  '

check "HTTPRoute 'store-route' exists in gw-demo" \
  kubectl get httproute store-route -n gw-demo

check "HTTPRoute parentRefs include demo-gateway" \
  bash -c '
    PARENT=$(kubectl get httproute store-route -n gw-demo -o jsonpath="{.spec.parentRefs[0].name}" 2>/dev/null)
    [[ "$PARENT" == "demo-gateway" ]]
  '

check "HTTPRoute matches path prefix /store" \
  bash -c '
    PATH_VAL=$(kubectl get httproute store-route -n gw-demo -o jsonpath="{.spec.rules[0].matches[0].path.value}" 2>/dev/null)
    [[ "$PATH_VAL" == "/store" ]]
  '

check "HTTPRoute backendRef points at store-backend on port 80" \
  bash -c '
    NAME=$(kubectl get httproute store-route -n gw-demo -o jsonpath="{.spec.rules[0].backendRefs[0].name}" 2>/dev/null)
    PORT=$(kubectl get httproute store-route -n gw-demo -o jsonpath="{.spec.rules[0].backendRefs[0].port}" 2>/dev/null)
    [[ "$NAME" == "store-backend" && "$PORT" == "80" ]]
  '

check "Gateway resource exists with a status block populated" \
  bash -c '
    kubectl get gateway demo-gateway -n gw-demo -o jsonpath="{.status}" 2>/dev/null | grep -q "."
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
echo "NOTE: Programmed/Accepted=True and ResolvedRefs=True checks depend on"
echo "a live Gateway controller reconciling these resources; structural"
echo "checks above validate the candidate's manifest correctness."
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
