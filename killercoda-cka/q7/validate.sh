#!/bin/bash
FAIL=0

if [ ! -f /opt/course/7/node.sh ]; then
  echo "FAIL: /opt/course/7/node.sh does not exist"
  FAIL=1
else
  if [ ! -x /opt/course/7/node.sh ]; then
    echo "FAIL: /opt/course/7/node.sh is not executable"
    FAIL=1
  fi
  OUT=$(bash /opt/course/7/node.sh 2>&1)
  if echo "$OUT" | grep -qE "^NAME.*CPU"; then
    echo "PASS: node.sh produces node resource usage output"
  else
    echo "FAIL: node.sh output does not look like 'kubectl top node' output:"
    echo "$OUT"
    FAIL=1
  fi
fi

if [ ! -f /opt/course/7/pod.sh ]; then
  echo "FAIL: /opt/course/7/pod.sh does not exist"
  FAIL=1
else
  if [ ! -x /opt/course/7/pod.sh ]; then
    echo "FAIL: /opt/course/7/pod.sh is not executable"
    FAIL=1
  fi
  OUT=$(bash /opt/course/7/pod.sh 2>&1)
  if echo "$OUT" | grep -qE "^POD|^NAME"; then
    echo "PASS: pod.sh produces pod resource usage output"
  else
    echo "FAIL: pod.sh output does not look like 'kubectl top pod' output:"
    echo "$OUT"
    FAIL=1
  fi
  if grep -q "\-\-containers" /opt/course/7/pod.sh; then
    echo "PASS: pod.sh uses --containers flag"
  else
    echo "FAIL: pod.sh should use 'kubectl top pod --containers' to show container usage"
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
