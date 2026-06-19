#!/bin/bash
# Validation script - Question 16: Multi-Tier Network Isolation
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
echo " Validating Question 16: Multi-Tier Isolation"
echo "============================================"

# ── Namespace "api" policies ──────────────────────────────────────────────────

check "NetworkPolicy 'allow-web-to-api' exists in namespace 'api'" \
  kubectl get networkpolicy allow-web-to-api -n api

check "allow-web-to-api targets tier=api pods" \
  bash -c '
    kubectl get networkpolicy allow-web-to-api -n api -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
labels = data[\"spec\"].get(\"podSelector\", {}).get(\"matchLabels\", {})
sys.exit(0 if labels.get(\"tier\") == \"api\" else 1)
"'

check "allow-web-to-api allows ingress from namespace 'web'" \
  bash -c '
    kubectl get networkpolicy allow-web-to-api -n api -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rule in data[\"spec\"].get(\"ingress\", []):
    for f in rule.get(\"from\", []):
        nssel = f.get(\"namespaceSelector\", {}).get(\"matchLabels\", {})
        if any(\"web\" in v for v in nssel.values()):
            sys.exit(0)
sys.exit(1)
"'

check "allow-web-to-api restricts to port 8080" \
  bash -c '
    kubectl get networkpolicy allow-web-to-api -n api -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rule in data[\"spec\"].get(\"ingress\", []):
    for p in rule.get(\"ports\", []):
        if p.get(\"port\") == 8080:
            sys.exit(0)
sys.exit(1)
"'

# ── Namespace "db" policies ───────────────────────────────────────────────────

check "NetworkPolicy 'default-deny-db' exists in namespace 'db'" \
  kubectl get networkpolicy default-deny-db -n db

check "default-deny-db uses empty podSelector (covers all db pods)" \
  bash -c '
    kubectl get networkpolicy default-deny-db -n db -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
sel = data[\"spec\"].get(\"podSelector\", {})
ml  = sel.get(\"matchLabels\", None)
me  = sel.get(\"matchExpressions\", None)
if (ml is None and me is None) or (ml == {} and not me):
    sys.exit(0)
sys.exit(1)
"'

check "default-deny-db blocks all ingress (Ingress type, no rules)" \
  bash -c '
    kubectl get networkpolicy default-deny-db -n db -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
types = data[\"spec\"].get(\"policyTypes\", [])
rules = data[\"spec\"].get(\"ingress\", [])
sys.exit(0 if \"Ingress\" in types and len(rules) == 0 else 1)
"'

check "NetworkPolicy 'allow-api-to-db' exists in namespace 'db'" \
  kubectl get networkpolicy allow-api-to-db -n db

check "allow-api-to-db targets tier=db pods" \
  bash -c '
    kubectl get networkpolicy allow-api-to-db -n db -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
labels = data[\"spec\"].get(\"podSelector\", {}).get(\"matchLabels\", {})
sys.exit(0 if labels.get(\"tier\") == \"db\" else 1)
"'

check "allow-api-to-db uses AND condition (namespace=api AND tier=api)" \
  bash -c '
    kubectl get networkpolicy allow-api-to-db -n db -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rule in data[\"spec\"].get(\"ingress\", []):
    for f in rule.get(\"from\", []):
        has_ns  = \"namespaceSelector\" in f
        has_pod = \"podSelector\" in f
        if has_ns and has_pod:
            ns_labels  = f[\"namespaceSelector\"].get(\"matchLabels\", {})
            pod_labels = f[\"podSelector\"].get(\"matchLabels\", {})
            ns_ok  = any(\"api\" in v for v in ns_labels.values())
            pod_ok = pod_labels.get(\"tier\") == \"api\"
            if ns_ok and pod_ok:
                sys.exit(0)
sys.exit(1)
"'

check "allow-api-to-db restricts to port 3306" \
  bash -c '
    kubectl get networkpolicy allow-api-to-db -n db -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rule in data[\"spec\"].get(\"ingress\", []):
    for p in rule.get(\"ports\", []):
        if p.get(\"port\") == 3306:
            sys.exit(0)
sys.exit(1)
"'

# ── Deployments running ───────────────────────────────────────────────────────

check "Deployment 'web-frontend' running in 'web'" \
  bash -c '[[ $(kubectl get deployment web-frontend -n web -o jsonpath="{.status.readyReplicas}" 2>/dev/null) -ge 1 ]]'

check "Deployment 'api-server' running in 'api'" \
  bash -c '[[ $(kubectl get deployment api-server -n api -o jsonpath="{.status.readyReplicas}" 2>/dev/null) -ge 1 ]]'

check "Deployment 'mysql' running in 'db'" \
  bash -c '[[ $(kubectl get deployment mysql -n db -o jsonpath="{.status.readyReplicas}" 2>/dev/null) -ge 1 ]]'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."

echo ""
echo "============================================"
echo " Manual Connectivity Tests"
echo "============================================"
echo 'WEB_POD=$(kubectl get pod -n web -l tier=web -o jsonpath='"'"'{.items[0].metadata.name}'"'"')'
echo 'API_POD=$(kubectl get pod -n api -l tier=api -o jsonpath='"'"'{.items[0].metadata.name}'"'"')'
echo ""
echo "web → api (should succeed):"
echo "  kubectl exec -n web \$WEB_POD -- curl -s --connect-timeout 5 api-service.api.svc.cluster.local:8080"
echo ""
echo "api → db (should succeed):"
echo "  kubectl exec -n api \$API_POD -- curl -s --connect-timeout 5 mysql-service.db.svc.cluster.local:3306"
echo ""
echo "web → db (should FAIL/timeout — the key check):"
echo "  kubectl exec -n web \$WEB_POD -- curl -s --connect-timeout 5 mysql-service.db.svc.cluster.local:3306"

exit $FAIL
