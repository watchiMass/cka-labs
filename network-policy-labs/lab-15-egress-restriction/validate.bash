#!/bin/bash
# Validation script - Question 15: Egress Restriction
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
echo " Validating Question 15: Egress Restriction"
echo "============================================"

# 1. Policy exists
check "NetworkPolicy 'restrict-egress-payments' exists in 'payments'" \
  kubectl get networkpolicy restrict-egress-payments -n payments

# 2. Egress is in policyTypes
check "Policy has 'Egress' in policyTypes" \
  bash -c '
    kubectl get networkpolicy restrict-egress-payments -n payments -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
types = data[\"spec\"].get(\"policyTypes\", [])
sys.exit(0 if \"Egress\" in types else 1)
"'

# 3. Policy targets app=payment-service
check "Policy targets pods with label app=payment-service" \
  bash -c '
    kubectl get networkpolicy restrict-egress-payments -n payments -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
labels = data[\"spec\"].get(\"podSelector\", {}).get(\"matchLabels\", {})
sys.exit(0 if labels.get(\"app\") == \"payment-service\" else 1)
"'

# 4. Has egress rules (not a complete deny-all)
check "Policy has at least one egress rule" \
  bash -c '
    kubectl get networkpolicy restrict-egress-payments -n payments -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
rules = data[\"spec\"].get(\"egress\", [])
sys.exit(0 if len(rules) >= 1 else 1)
"'

# 5. Allows egress to database namespace
check "Policy allows egress to namespace 'database'" \
  bash -c '
    kubectl get networkpolicy restrict-egress-payments -n payments -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rule in data[\"spec\"].get(\"egress\", []):
    for t in rule.get(\"to\", []):
        nssel = t.get(\"namespaceSelector\", {}).get(\"matchLabels\", {})
        for v in nssel.values():
            if \"database\" in v:
                sys.exit(0)
sys.exit(1)
"'

# 6. Allows egress on port 5432 (postgres)
check "Policy allows egress on port 5432 (postgres)" \
  bash -c '
    kubectl get networkpolicy restrict-egress-payments -n payments -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rule in data[\"spec\"].get(\"egress\", []):
    for p in rule.get(\"ports\", []):
        if p.get(\"port\") == 5432:
            sys.exit(0)
sys.exit(1)
"'

# 7. Allows egress to kube-system (DNS)
check "Policy allows egress to kube-system on UDP/53 (DNS)" \
  bash -c '
    kubectl get networkpolicy restrict-egress-payments -n payments -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rule in data[\"spec\"].get(\"egress\", []):
    has_dns_port = any(
        p.get(\"port\") == 53 and p.get(\"protocol\") == \"UDP\"
        for p in rule.get(\"ports\", [])
    )
    if not has_dns_port:
        continue
    # Accept either an explicit kube-system selector or an open namespaceSelector for DNS
    tos = rule.get(\"to\", [])
    if not tos:   # open egress rule with just a port (also valid for DNS)
        sys.exit(0)
    for t in tos:
        nssel = t.get(\"namespaceSelector\", {}).get(\"matchLabels\", {})
        for v in nssel.values():
            if \"kube-system\" in v:
                sys.exit(0)
sys.exit(1)
"'

# 8. Deployments are running
check "Deployment 'payment-service' running in 'payments'" \
  bash -c '[[ $(kubectl get deployment payment-service -n payments -o jsonpath="{.status.readyReplicas}" 2>/dev/null) -ge 1 ]]'

check "Deployment 'postgres' running in 'database'" \
  bash -c '[[ $(kubectl get deployment postgres -n database -o jsonpath="{.status.readyReplicas}" 2>/dev/null) -ge 1 ]]'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."

echo ""
echo "============================================"
echo " Manual Connectivity Tests"
echo "============================================"
echo 'PAYMENT_POD=$(kubectl get pod -n payments -l app=payment-service -o jsonpath='"'"'{.items[0].metadata.name}'"'"')'
echo ""
echo "Postgres (should succeed):"
echo "  kubectl exec -n payments \$PAYMENT_POD -- curl -s --connect-timeout 5 postgres-service.database.svc.cluster.local:5432"
echo ""
echo "External (should fail/timeout):"
echo "  kubectl exec -n payments \$PAYMENT_POD -- curl -s --connect-timeout 5 external-api-service.external.svc.cluster.local:80"

exit $FAIL
