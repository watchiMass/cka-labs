#!/bin/bash
FAIL=0
NS=project-snake

NP_JSON=$(kubectl -n $NS get networkpolicy np-backend -o json 2>/dev/null)
if [ -z "$NP_JSON" ]; then
  echo "FAIL: NetworkPolicy np-backend not found in $NS"
  exit 1
fi

POD_SEL=$(echo "$NP_JSON" | jq -r '.spec.podSelector.matchLabels.app // ""')
if echo "$POD_SEL" | grep -q "backend"; then
  echo "PASS: podSelector targets backend app label ('$POD_SEL')"
else
  echo "FAIL: podSelector.matchLabels.app='$POD_SEL', expected something matching backend"
  FAIL=1
fi

POLICY_TYPES=$(echo "$NP_JSON" | jq -r '.spec.policyTypes[]' | tr '\n' ',')
if echo "$POLICY_TYPES" | grep -q "Egress"; then
  echo "PASS: policyTypes includes Egress"
else
  echo "FAIL: policyTypes does not include Egress (got: $POLICY_TYPES)"
  FAIL=1
fi

DB1_MATCH=$(echo "$NP_JSON" | jq -r '.spec.egress[] | select(.ports[]?.port==1111) | .to[]?.podSelector.matchLabels.app // empty' 2>/dev/null | head -1)
DB2_MATCH=$(echo "$NP_JSON" | jq -r '.spec.egress[] | select(.ports[]?.port==2222) | .to[]?.podSelector.matchLabels.app // empty' 2>/dev/null | head -1)

if echo "$DB1_MATCH" | grep -q "db1"; then
  echo "PASS: egress rule for port 1111 targets db1 app label"
else
  echo "FAIL: no egress rule found allowing port 1111 to db1-* pods"
  FAIL=1
fi

if echo "$DB2_MATCH" | grep -q "db2"; then
  echo "PASS: egress rule for port 2222 targets db2 app label"
else
  echo "FAIL: no egress rule found allowing port 2222 to db2-* pods"
  FAIL=1
fi

# Functional test (best-effort - depends on CNI supporting NetworkPolicy)
echo "Running functional connectivity tests (requires CNI with NetworkPolicy support)..."
kubectl -n $NS run test-backend --image=busybox:1 --labels="app=backend-1" --restart=Never --command -- sleep 3600 &>/dev/null
sleep 5
kubectl -n $NS wait --for=condition=ready pod/test-backend --timeout=30s &>/dev/null

DB1_OK=$(kubectl -n $NS exec test-backend -- sh -c 'nc -z -w3 db1-main 1111 && echo OK' 2>/dev/null)
OTHER_BLOCKED=$(kubectl -n $NS exec test-backend -- sh -c 'nc -z -w3 other-app 3333 && echo OK' 2>/dev/null)

if [ "$DB1_OK" == "OK" ]; then
  echo "PASS: backend pod CAN reach db1-main:1111 (allowed traffic works)"
else
  echo "WARN: backend pod could not reach db1-main:1111 - check policy or CNI support"
fi

if [ "$OTHER_BLOCKED" != "OK" ]; then
  echo "PASS: backend pod is BLOCKED from reaching other-app:3333 (unrelated traffic denied)"
else
  echo "FAIL: backend pod could reach other-app:3333 - egress not properly restricted (or CNI doesn't enforce NetworkPolicy)"
  FAIL=1
fi

kubectl -n $NS delete pod test-backend --ignore-not-found=true --wait=false &>/dev/null

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED ===="
  exit 1
fi
