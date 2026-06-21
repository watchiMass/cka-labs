#!/bin/bash
# Validation script for Question 12 - Ingress with TLS
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
echo " Validating Question 12: Ingress with TLS"
echo "==========================================="

check "Ingress 'shop-ingress' exists in ingress-demo" \
  kubectl get ingress shop-ingress -n ingress-demo

check "Ingress uses ingressClassName 'nginx'" \
  bash -c '
    CLASS=$(kubectl get ingress shop-ingress -n ingress-demo -o jsonpath="{.spec.ingressClassName}" 2>/dev/null)
    [[ "$CLASS" == "nginx" ]]
  '

check "Ingress TLS block references shop-tls-secret for shop.example.com" \
  bash -c '
    HOST=$(kubectl get ingress shop-ingress -n ingress-demo -o jsonpath="{.spec.tls[0].hosts[0]}" 2>/dev/null)
    SECRET=$(kubectl get ingress shop-ingress -n ingress-demo -o jsonpath="{.spec.tls[0].secretName}" 2>/dev/null)
    [[ "$HOST" == "shop.example.com" && "$SECRET" == "shop-tls-secret" ]]
  '

check "Ingress has rewrite-target annotation set to /" \
  bash -c '
    ANN=$(kubectl get ingress shop-ingress -n ingress-demo -o jsonpath="{.metadata.annotations.nginx\.ingress\.kubernetes\.io/rewrite-target}" 2>/dev/null)
    [[ "$ANN" == "/" ]]
  '

check "Path /shop routes to Service shop-app on port 80" \
  bash -c '
    kubectl get ingress shop-ingress -n ingress-demo -o json 2>/dev/null | \
    python3 -c "
import json,sys
d = json.load(sys.stdin)
paths = d[\"spec\"][\"rules\"][0][\"http\"][\"paths\"]
ok = any(p[\"path\"]==\"/shop\" and p[\"backend\"][\"service\"][\"name\"]==\"shop-app\" and p[\"backend\"][\"service\"][\"port\"][\"number\"]==80 for p in paths)
sys.exit(0 if ok else 1)
"
  '

check "Path /blog routes to Service blog-app on port 80" \
  bash -c '
    kubectl get ingress shop-ingress -n ingress-demo -o json 2>/dev/null | \
    python3 -c "
import json,sys
d = json.load(sys.stdin)
paths = d[\"spec\"][\"rules\"][0][\"http\"][\"paths\"]
ok = any(p[\"path\"]==\"/blog\" and p[\"backend\"][\"service\"][\"name\"]==\"blog-app\" and p[\"backend\"][\"service\"][\"port\"][\"number\"]==80 for p in paths)
sys.exit(0 if ok else 1)
"
  '

check "TLS secret shop-tls-secret exists and contains tls.crt/tls.key" \
  bash -c '
    CRT=$(kubectl get secret shop-tls-secret -n ingress-demo -o jsonpath="{.data.tls\.crt}" 2>/dev/null)
    KEY=$(kubectl get secret shop-tls-secret -n ingress-demo -o jsonpath="{.data.tls\.key}" 2>/dev/null)
    [[ -n "$CRT" && -n "$KEY" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
