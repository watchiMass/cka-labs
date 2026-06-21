#!/bin/bash
# Validation script for Question 17 - TLS Cert Mismatch
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
echo " Validating Question 17: TLS Cert Mismatch"
echo "==========================================="

check "Secret 'api-tls-secret' exists in tls-demo" \
  kubectl get secret api-tls-secret -n tls-demo

check "Ingress still references api-tls-secret and api.example.com (unchanged)" \
  bash -c '
    HOST=$(kubectl get ingress api-ingress -n tls-demo -o jsonpath="{.spec.tls[0].hosts[0]}" 2>/dev/null)
    SECRET=$(kubectl get ingress api-ingress -n tls-demo -o jsonpath="{.spec.tls[0].secretName}" 2>/dev/null)
    [[ "$HOST" == "api.example.com" && "$SECRET" == "api-tls-secret" ]]
  '

check "Certificate inside the secret now has CN=api.example.com" \
  bash -c '
    SUBJECT=$(kubectl get secret api-tls-secret -n tls-demo -o jsonpath="{.data.tls\.crt}" | base64 -d | openssl x509 -noout -subject 2>/dev/null)
    [[ "$SUBJECT" == *"api.example.com"* ]]
  '

check "Certificate inside the secret does NOT reference wrong-host.example.com" \
  bash -c '
    SUBJECT=$(kubectl get secret api-tls-secret -n tls-demo -o jsonpath="{.data.tls\.crt}" | base64 -d | openssl x509 -noout -subject 2>/dev/null)
    [[ "$SUBJECT" != *"wrong-host.example.com"* ]]
  '

check "Certificate SAN includes DNS:api.example.com" \
  bash -c '
    SAN=$(kubectl get secret api-tls-secret -n tls-demo -o jsonpath="{.data.tls\.crt}" | base64 -d | openssl x509 -noout -ext subjectAltName 2>/dev/null)
    [[ "$SAN" == *"api.example.com"* ]]
  '

check "Secret still contains both tls.crt and tls.key" \
  bash -c '
    CRT=$(kubectl get secret api-tls-secret -n tls-demo -o jsonpath="{.data.tls\.crt}" 2>/dev/null)
    KEY=$(kubectl get secret api-tls-secret -n tls-demo -o jsonpath="{.data.tls\.key}" 2>/dev/null)
    [[ -n "$CRT" && -n "$KEY" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
