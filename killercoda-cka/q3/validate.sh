#!/bin/bash
FAIL=0

STS_NAME=$(kubectl -n project-h800 get statefulset -o jsonpath='{.items[?(@.metadata.name)].metadata.name}' 2>/dev/null | tr ' ' '\n' | grep '^o3db' | head -1)

if [ -z "$STS_NAME" ]; then
  echo "FAIL: no StatefulSet matching o3db found in namespace project-h800"
  FAIL=1
else
  REPLICAS=$(kubectl -n project-h800 get statefulset "$STS_NAME" -o jsonpath='{.spec.replicas}')
  if [ "$REPLICAS" == "1" ]; then
    echo "PASS: StatefulSet $STS_NAME has replicas=1"
  else
    echo "FAIL: StatefulSet $STS_NAME has replicas=$REPLICAS, expected 1"
    FAIL=1
  fi

  READY_PODS=$(kubectl -n project-h800 get pods -l app=o3db --no-headers 2>/dev/null | grep -c "1/1")
  TOTAL_PODS=$(kubectl -n project-h800 get pods --no-headers 2>/dev/null | grep -c "^o3db")
  if [ "$TOTAL_PODS" == "1" ]; then
    echo "PASS: only 1 o3db pod exists"
  else
    echo "FAIL: expected 1 o3db pod, found $TOTAL_PODS"
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
