#!/bin/bash
# Run this on the controlplane node.
FAIL=0

CP_VERSION=$(kubectl version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion')

NODE_JSON=$(kubectl get node node01 -o json 2>/dev/null)
if [ -z "$NODE_JSON" ]; then
  echo "FAIL: node01 is not part of the cluster"
  FAIL=1
else
  echo "PASS: node01 has joined the cluster"

  NODE_VERSION=$(echo "$NODE_JSON" | jq -r '.status.nodeInfo.kubeletVersion')
  if [ "$NODE_VERSION" == "$CP_VERSION" ]; then
    echo "PASS: node01 kubelet version ($NODE_VERSION) matches controlplane ($CP_VERSION)"
  else
    echo "FAIL: node01 kubelet version ($NODE_VERSION) does not match controlplane ($CP_VERSION)"
    FAIL=1
  fi

  READY=$(echo "$NODE_JSON" | jq -r '.status.conditions[] | select(.type=="Ready") | .status')
  if [ "$READY" == "True" ]; then
    echo "PASS: node01 is Ready"
  else
    echo "FAIL: node01 is not Ready (status=$READY)"
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
