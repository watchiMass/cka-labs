#!/bin/bash
# Validation script - Question 14: Default Deny + Selective Allow
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
echo " Validating Question 14: Default Deny + Selective Allow"
echo "============================================"

# 1. NetworkPolicy "default-deny-ingress" exists
check "NetworkPolicy 'default-deny-ingress' exists in namespace 'app'" \
  kubectl get networkpolicy default-deny-ingress -n app

# 2. default-deny-ingress selects all pods (empty podSelector) and has no ingress rules
check "default-deny-ingress uses empty podSelector (denies all pods)" \
  bash -c '
    kubectl get networkpolicy default-deny-ingress -n app -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
sel = data[\"spec\"].get(\"podSelector\", {})
match_labels = sel.get(\"matchLabels\", None)
match_expr   = sel.get(\"matchExpressions\", None)
# Empty podSelector = {} or {matchLabels: {}} or {matchExpressions: []}
if match_labels is None and match_expr is None:
    sys.exit(0)
if match_labels == {} and not match_expr:
    sys.exit(0)
sys.exit(1)
"'

# 3. default-deny-ingress has Ingress in policyTypes and no ingress rules
check "default-deny-ingress blocks all ingress (Ingress policyType, no rules)" \
  bash -c '
    kubectl get networkpolicy default-deny-ingress -n app -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
types = data[\"spec\"].get(\"policyTypes\", [])
ingress_rules = data[\"spec\"].get(\"ingress\", [])
if \"Ingress\" in types and len(ingress_rules) == 0:
    sys.exit(0)
sys.exit(1)
"'

# 4. NetworkPolicy "allow-prometheus" exists
check "NetworkPolicy 'allow-prometheus' exists in namespace 'app'" \
  kubectl get networkpolicy allow-prometheus -n app

# 5. allow-prometheus restricts to pods with app=webapp
check "allow-prometheus targets pods with label app=webapp" \
  bash -c '
    kubectl get networkpolicy allow-prometheus -n app -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
labels = data[\"spec\"].get(\"podSelector\", {}).get(\"matchLabels\", {})
if labels.get(\"app\") == \"webapp\":
    sys.exit(0)
sys.exit(1)
"'

# 6. allow-prometheus allows only from namespace=monitoring AND pod=prometheus (AND condition)
check "allow-prometheus uses AND condition (same namespaceSelector + podSelector)" \
  bash -c '
    kubectl get networkpolicy allow-prometheus -n app -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rule in data[\"spec\"].get(\"ingress\", []):
    for f in rule.get(\"from\", []):
        has_ns  = \"namespaceSelector\" in f
        has_pod = \"podSelector\" in f
        if has_ns and has_pod:
            ns_labels = f[\"namespaceSelector\"].get(\"matchLabels\", {})
            pod_labels = f[\"podSelector\"].get(\"matchLabels\", {})
            ns_ok  = any(\"monitoring\" in v for v in ns_labels.values())
            pod_ok = pod_labels.get(\"app\") == \"prometheus\"
            if ns_ok and pod_ok:
                sys.exit(0)
sys.exit(1)
"'

# 7. allow-prometheus restricts to port 80
check "allow-prometheus allows only port 80" \
  bash -c '
    kubectl get networkpolicy allow-prometheus -n app -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rule in data[\"spec\"].get(\"ingress\", []):
    ports = rule.get(\"ports\", [])
    for p in ports:
        if p.get(\"port\") == 80:
            sys.exit(0)
sys.exit(1)
"'

# 8. webapp deployment is running
check "Deployment 'webapp' is running in namespace 'app'" \
  bash -c '
    READY=$(kubectl get deployment webapp -n app -o jsonpath="{.status.readyReplicas}" 2>/dev/null)
    [[ "${READY}" -ge 1 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."

echo ""
echo "============================================"
echo " Manual Connectivity Test"
echo "============================================"
echo "Prometheus → webapp (should succeed):"
echo '  PROMETHEUS_POD=$(kubectl get pod -n monitoring -l app=prometheus -o jsonpath='"'"'{.items[0].metadata.name}'"'"')'
echo '  kubectl exec -n monitoring $PROMETHEUS_POD -- curl -s --connect-timeout 5 webapp-service.app.svc.cluster.local:80'
echo ""
echo "Rogue → webapp (should timeout/fail):"
echo '  ROGUE_POD=$(kubectl get pod -n monitoring -l app=rogue -o jsonpath='"'"'{.items[0].metadata.name}'"'"')'
echo '  kubectl exec -n monitoring $ROGUE_POD -- curl -s --connect-timeout 5 webapp-service.app.svc.cluster.local:80'

exit $FAIL
