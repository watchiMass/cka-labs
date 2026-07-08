#!/bin/bash
source /root/.candidate/utils.sh 2>/dev/null || true

FAIL=0

# Expected contexts
EXPECTED_CONTEXTS=$(kubectl config get-contexts --kubeconfig=/opt/course/1/kubeconfig -o name | sort)

if [ ! -f /opt/course/1/contexts ]; then
  echo "FAIL: /opt/course/1/contexts does not exist"
  FAIL=1
else
  ACTUAL_CONTEXTS=$(sort /opt/course/1/contexts)
  if [ "$EXPECTED_CONTEXTS" == "$ACTUAL_CONTEXTS" ]; then
    echo "PASS: contexts file correct"
  else
    echo "FAIL: contexts file content incorrect"
    echo "Expected:"
    echo "$EXPECTED_CONTEXTS"
    echo "Got:"
    echo "$ACTUAL_CONTEXTS"
    FAIL=1
  fi
fi

if [ ! -f /opt/course/1/current-context ]; then
  echo "FAIL: /opt/course/1/current-context does not exist"
  FAIL=1
else
  EXPECTED_CURRENT=$(kubectl config current-context --kubeconfig=/opt/course/1/kubeconfig)
  ACTUAL_CURRENT=$(cat /opt/course/1/current-context | tr -d '[:space:]')
  if [ "$EXPECTED_CURRENT" == "$ACTUAL_CURRENT" ]; then
    echo "PASS: current-context file correct"
  else
    echo "FAIL: current-context incorrect. Expected '$EXPECTED_CURRENT', got '$ACTUAL_CURRENT'"
    FAIL=1
  fi
fi

if [ ! -f /opt/course/1/cert ]; then
  echo "FAIL: /opt/course/1/cert does not exist"
  FAIL=1
else
  EXPECTED_CERT=$(kubectl config view --kubeconfig=/opt/course/1/kubeconfig --raw -o jsonpath='{.users[?(@.name=="account-0027")].user.client-certificate-data}' | base64 -d)
  ACTUAL_CERT=$(cat /opt/course/1/cert)
  if [ "$EXPECTED_CERT" == "$ACTUAL_CERT" ]; then
    echo "PASS: cert file correct"
  else
    echo "FAIL: cert file content incorrect"
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
