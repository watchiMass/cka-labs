#!/bin/bash
FAIL=0
NS=project-r500

HR_JSON=$(kubectl -n $NS get httproute traffic-director -o json 2>/dev/null)
if [ -z "$HR_JSON" ]; then
  echo "FAIL: HTTPRoute traffic-director not found in $NS"
  exit 1
fi

PARENT=$(echo "$HR_JSON" | jq -r '.spec.parentRefs[0].name // ""')
[ "$PARENT" == "r500-gateway" ] && echo "PASS: HTTPRoute parentRefs points to r500-gateway" || { echo "FAIL: parentRefs name='$PARENT'"; FAIL=1; }

# Functional test via NodePort 30080 (assumes gateway svc has been exposed there)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
if [ -z "$NODE_IP" ]; then
  NODE_IP="127.0.0.1"
fi

test_route() {
  local path=$1
  local ua=$2
  local expected_backend_marker=$3
  local desc=$4
  if [ -n "$ua" ]; then
    RESP=$(curl -s --resolve r500.gateway:30080:$NODE_IP -H "User-Agent: $ua" "http://r500.gateway:30080$path" -o /dev/null -w "%{http_code}" --max-time 5)
  else
    RESP=$(curl -s --resolve r500.gateway:30080:$NODE_IP "http://r500.gateway:30080$path" -o /dev/null -w "%{http_code}" --max-time 5)
  fi
  if [ "$RESP" == "200" ]; then
    echo "PASS: $desc returned HTTP 200"
  else
    echo "FAIL: $desc returned HTTP $RESP (expected 200)"
    FAIL=1
  fi
}

test_route "/desktop" "" "" "curl /desktop"
test_route "/mobile" "" "" "curl /mobile"
test_route "/auto" "mobile" "" "curl /auto with User-Agent: mobile"
test_route "/auto" "" "" "curl /auto without special User-Agent"

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED (verify Gateway is exposed on NodePort 30080 and DNS/hosts resolve r500.gateway) ===="
  exit 1
fi
