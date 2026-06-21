#!/bin/bash
# Validation script for Question 6 - cert-manager Issuer/Certificate
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
echo " Validating Question 6: cert-manager"
echo "==========================================="

check "cert-manager CRDs are installed" \
  bash -c 'kubectl get crd certificates.cert-manager.io'

check "ClusterIssuer 'selfsigned-issuer' exists" \
  kubectl get clusterissuer selfsigned-issuer

check "ClusterIssuer is self-signed type" \
  bash -c '
    kubectl get clusterissuer selfsigned-issuer -o jsonpath="{.spec.selfSigned}" 2>/dev/null | grep -q "{}"
  '

check "Certificate 'internal-tls' exists in cert-demo" \
  kubectl get certificate internal-tls -n cert-demo

check "Certificate references selfsigned-issuer ClusterIssuer" \
  bash -c '
    NAME=$(kubectl get certificate internal-tls -n cert-demo -o jsonpath="{.spec.issuerRef.name}" 2>/dev/null)
    KIND=$(kubectl get certificate internal-tls -n cert-demo -o jsonpath="{.spec.issuerRef.kind}" 2>/dev/null)
    [[ "$NAME" == "selfsigned-issuer" && "$KIND" == "ClusterIssuer" ]]
  '

check "Certificate secretName is internal-tls-secret" \
  bash -c '
    SN=$(kubectl get certificate internal-tls -n cert-demo -o jsonpath="{.spec.secretName}" 2>/dev/null)
    [[ "$SN" == "internal-tls-secret" ]]
  '

check "Certificate status is Ready=True" \
  bash -c '
    READY=$(kubectl get certificate internal-tls -n cert-demo -o jsonpath="{.status.conditions[?(@.type==\"Ready\")].status}" 2>/dev/null)
    [[ "$READY" == "True" ]]
  '

check "Secret internal-tls-secret exists with tls.crt and tls.key" \
  bash -c '
    CRT=$(kubectl get secret internal-tls-secret -n cert-demo -o jsonpath="{.data.tls\.crt}" 2>/dev/null)
    KEY=$(kubectl get secret internal-tls-secret -n cert-demo -o jsonpath="{.data.tls\.key}" 2>/dev/null)
    [[ -n "$CRT" && -n "$KEY" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
