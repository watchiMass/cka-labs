#!/bin/bash
FAIL=0
NS=project-tiger

DS_JSON=$(kubectl -n $NS get daemonset ds-important -o json 2>/dev/null)
if [ -z "$DS_JSON" ]; then
  echo "FAIL: DaemonSet ds-important not found in $NS"
  exit 1
fi

IMAGE=$(echo "$DS_JSON" | jq -r '.spec.template.spec.containers[0].image')
[ "$IMAGE" == "httpd:2-alpine" ] && echo "PASS: image=httpd:2-alpine" || { echo "FAIL: image=$IMAGE"; FAIL=1; }

LBL_ID=$(echo "$DS_JSON" | jq -r '.metadata.labels.id // ""')
LBL_UUID=$(echo "$DS_JSON" | jq -r '.metadata.labels.uuid // ""')
[ "$LBL_ID" == "ds-important" ] && echo "PASS: label id=ds-important" || { echo "FAIL: label id='$LBL_ID'"; FAIL=1; }
[ "$LBL_UUID" == "18426a0b-5f59-4e10-923f-c0e078e82462" ] && echo "PASS: label uuid correct" || { echo "FAIL: label uuid='$LBL_UUID'"; FAIL=1; }

CPU_REQ=$(echo "$DS_JSON" | jq -r '.spec.template.spec.containers[0].resources.requests.cpu // ""')
MEM_REQ=$(echo "$DS_JSON" | jq -r '.spec.template.spec.containers[0].resources.requests.memory // ""')
if [ "$CPU_REQ" == "10m" ]; then
  echo "PASS: cpu request = 10m"
else
  echo "FAIL: cpu request = '$CPU_REQ', expected 10m"
  FAIL=1
fi
if [ "$MEM_REQ" == "10Mi" ]; then
  echo "PASS: memory request = 10Mi"
else
  echo "FAIL: memory request = '$MEM_REQ', expected 10Mi"
  FAIL=1
fi

TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
DESIRED=$(echo "$DS_JSON" | jq -r '.status.desiredNumberScheduled')
CURRENT=$(echo "$DS_JSON" | jq -r '.status.currentNumberScheduled')

if [ "$DESIRED" == "$TOTAL_NODES" ]; then
  echo "PASS: DaemonSet desired to run on all $TOTAL_NODES nodes"
else
  echo "FAIL: DaemonSet desiredNumberScheduled=$DESIRED, expected $TOTAL_NODES (all nodes incl. controlplane)"
  FAIL=1
fi

if [ "$CURRENT" == "$TOTAL_NODES" ]; then
  echo "PASS: DaemonSet currently scheduled on all $TOTAL_NODES nodes"
else
  echo "FAIL: DaemonSet currentNumberScheduled=$CURRENT, expected $TOTAL_NODES"
  FAIL=1
fi

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED ===="
  exit 1
fi
