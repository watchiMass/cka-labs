#!/bin/bash
FAIL=0
NS=project-tiger

DEP_JSON=$(kubectl -n $NS get deployment deploy-important -o json 2>/dev/null)
if [ -z "$DEP_JSON" ]; then
  echo "FAIL: Deployment deploy-important not found in $NS"
  exit 1
fi

REPLICAS=$(echo "$DEP_JSON" | jq -r '.spec.replicas')
[ "$REPLICAS" == "3" ] && echo "PASS: replicas=3" || { echo "FAIL: replicas=$REPLICAS"; FAIL=1; }

DEP_LBL=$(echo "$DEP_JSON" | jq -r '.metadata.labels.id // ""')
POD_LBL=$(echo "$DEP_JSON" | jq -r '.spec.template.metadata.labels.id // ""')
[ "$DEP_LBL" == "very-important" ] && echo "PASS: Deployment label id=very-important" || { echo "FAIL: Deployment label='$DEP_LBL'"; FAIL=1; }
[ "$POD_LBL" == "very-important" ] && echo "PASS: Pod template label id=very-important" || { echo "FAIL: Pod label='$POD_LBL'"; FAIL=1; }

C1_NAME=$(echo "$DEP_JSON" | jq -r '.spec.template.spec.containers[0].name')
C1_IMAGE=$(echo "$DEP_JSON" | jq -r '.spec.template.spec.containers[0].image')
C2_NAME=$(echo "$DEP_JSON" | jq -r '.spec.template.spec.containers[1].name // ""')
C2_IMAGE=$(echo "$DEP_JSON" | jq -r '.spec.template.spec.containers[1].image // ""')

[ "$C1_NAME" == "container1" ] && echo "PASS: container1 name correct" || { echo "FAIL: first container name='$C1_NAME'"; FAIL=1; }
[ "$C1_IMAGE" == "nginx:1-alpine" ] && echo "PASS: container1 image correct" || { echo "FAIL: container1 image='$C1_IMAGE'"; FAIL=1; }
[ "$C2_NAME" == "container2" ] && echo "PASS: container2 name correct" || { echo "FAIL: second container name='$C2_NAME'"; FAIL=1; }
[ "$C2_IMAGE" == "registry.k8s.io/pause:3.10" ] && echo "PASS: container2 image correct" || { echo "FAIL: container2 image='$C2_IMAGE'"; FAIL=1; }

TOPOKEY=$(echo "$DEP_JSON" | jq -r '.spec.template.spec.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey // ""')
[ "$TOPOKEY" == "kubernetes.io/hostname" ] && echo "PASS: podAntiAffinity topologyKey correct" || { echo "FAIL: topologyKey='$TOPOKEY'"; FAIL=1; }

MATCH_LBL=$(echo "$DEP_JSON" | jq -r '.spec.template.spec.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchLabels.id // ""')
[ "$MATCH_LBL" == "very-important" ] && echo "PASS: podAntiAffinity matches label id=very-important" || { echo "FAIL: matchLabels.id='$MATCH_LBL'"; FAIL=1; }

# Verify actual scheduling: at most 1 pod per node
sleep 5
PODS_JSON=$(kubectl -n $NS get pods -l id=very-important -o json 2>/dev/null)
NODE_COUNTS=$(echo "$PODS_JSON" | jq -r '.items[].spec.nodeName' | sort | uniq -c | awk '{print $1}' | sort -u)
DUPLICATE=$(echo "$NODE_COUNTS" | awk '$1 > 1' | wc -l)
if [ "$DUPLICATE" -eq 0 ]; then
  echo "PASS: no node has more than 1 Pod of deploy-important scheduled"
else
  echo "FAIL: some node has more than 1 Pod scheduled (anti-affinity not effective, or too few nodes)"
  FAIL=1
fi

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED ===="
  exit 1
fi
