#!/bin/bash
FAIL=0

# Pod checks
POD_JSON=$(kubectl -n project-swan get pod api-contact -o json 2>/dev/null)
if [ -z "$POD_JSON" ]; then
  echo "FAIL: Pod api-contact not found in project-swan"
  FAIL=1
else
  IMAGE=$(echo "$POD_JSON" | jq -r '.spec.containers[0].image')
  SA=$(echo "$POD_JSON" | jq -r '.spec.serviceAccountName')

  [ "$IMAGE" == "nginx:1-alpine" ] && echo "PASS: Pod uses image nginx:1-alpine" || { echo "FAIL: image=$IMAGE"; FAIL=1; }
  [ "$SA" == "secret-reader" ] && echo "PASS: Pod uses ServiceAccount secret-reader" || { echo "FAIL: serviceAccountName=$SA"; FAIL=1; }
fi

# Result file checks
if [ ! -f /opt/course/9/result.json ]; then
  echo "FAIL: /opt/course/9/result.json does not exist"
  FAIL=1
else
  if jq -e '.kind == "SecretList"' /opt/course/9/result.json &>/dev/null; then
    echo "PASS: result.json contains a valid SecretList response"
  else
    echo "FAIL: result.json does not look like a valid Kubernetes API SecretList response"
    FAIL=1
  fi

  COUNT=$(jq '.items | length' /opt/course/9/result.json 2>/dev/null)
  ACTUAL_COUNT=$(kubectl -n project-swan get secrets --no-headers 2>/dev/null | wc -l)
  if [ "$COUNT" == "$ACTUAL_COUNT" ]; then
    echo "PASS: result.json contains the expected number of secrets ($COUNT)"
  else
    echo "FAIL: result.json contains $COUNT secrets, expected $ACTUAL_COUNT"
    FAIL=1
  fi
fi

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED ===="
  exit 1
fi
