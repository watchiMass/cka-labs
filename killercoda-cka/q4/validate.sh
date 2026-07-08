#!/bin/bash
FAIL=0

if [ ! -f /opt/course/4/pods-terminated-first.txt ]; then
  echo "FAIL: /opt/course/4/pods-terminated-first.txt does not exist"
  exit 1
fi

EXPECTED=$(kubectl -n project-c13 get pods -o json | jq -r '.items[] | select(.status.qosClass=="BestEffort") | .metadata.name' | sort)
ACTUAL=$(grep -v '^\s*$' /opt/course/4/pods-terminated-first.txt | sort)

if [ "$EXPECTED" == "$ACTUAL" ]; then
  echo "PASS: pods-terminated-first.txt contains exactly the BestEffort QoS pods"
else
  echo "FAIL: content mismatch"
  echo "Expected (BestEffort QoS pods):"
  echo "$EXPECTED"
  echo "Got:"
  echo "$ACTUAL"
  FAIL=1
fi

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED ===="
  exit 1
fi
