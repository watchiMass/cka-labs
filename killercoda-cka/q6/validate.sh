#!/bin/bash
FAIL=0

PV_JSON=$(kubectl get pv safari-pv -o json 2>/dev/null)
if [ -z "$PV_JSON" ]; then
  echo "FAIL: PV safari-pv not found"
  FAIL=1
else
  CAP=$(echo "$PV_JSON" | jq -r '.spec.capacity.storage')
  MODE=$(echo "$PV_JSON" | jq -r '.spec.accessModes[0]')
  HOSTPATH=$(echo "$PV_JSON" | jq -r '.spec.hostPath.path')
  SC=$(echo "$PV_JSON" | jq -r '.spec.storageClassName // ""')

  [ "$CAP" == "2Gi" ] && echo "PASS: PV capacity=2Gi" || { echo "FAIL: PV capacity=$CAP"; FAIL=1; }
  [ "$MODE" == "ReadWriteOnce" ] && echo "PASS: PV accessMode=ReadWriteOnce" || { echo "FAIL: PV accessMode=$MODE"; FAIL=1; }
  [ "$HOSTPATH" == "/Volumes/Data" ] && echo "PASS: PV hostPath=/Volumes/Data" || { echo "FAIL: PV hostPath=$HOSTPATH"; FAIL=1; }
  [ -z "$SC" ] && echo "PASS: PV has no storageClassName" || { echo "FAIL: PV storageClassName='$SC', expected none"; FAIL=1; }
fi

PVC_JSON=$(kubectl -n project-t230 get pvc safari-pvc -o json 2>/dev/null)
if [ -z "$PVC_JSON" ]; then
  echo "FAIL: PVC safari-pvc not found in project-t230"
  FAIL=1
else
  REQ=$(echo "$PVC_JSON" | jq -r '.spec.resources.requests.storage')
  MODE=$(echo "$PVC_JSON" | jq -r '.spec.accessModes[0]')
  SC=$(echo "$PVC_JSON" | jq -r '.spec.storageClassName // ""')
  PHASE=$(echo "$PVC_JSON" | jq -r '.status.phase')
  BOUND_PV=$(echo "$PVC_JSON" | jq -r '.spec.volumeName // ""')

  [ "$REQ" == "2Gi" ] && echo "PASS: PVC requests 2Gi" || { echo "FAIL: PVC requests=$REQ"; FAIL=1; }
  [ "$MODE" == "ReadWriteOnce" ] && echo "PASS: PVC accessMode=ReadWriteOnce" || { echo "FAIL: PVC accessMode=$MODE"; FAIL=1; }
  [ -z "$SC" ] && echo "PASS: PVC has no storageClassName" || { echo "FAIL: PVC storageClassName='$SC'"; FAIL=1; }
  [ "$PHASE" == "Bound" ] && echo "PASS: PVC is Bound" || { echo "FAIL: PVC phase=$PHASE, expected Bound"; FAIL=1; }
  [ "$BOUND_PV" == "safari-pv" ] && echo "PASS: PVC bound to safari-pv" || { echo "FAIL: PVC bound to '$BOUND_PV', expected safari-pv"; FAIL=1; }
fi

DEP_JSON=$(kubectl -n project-t230 get deployment safari -o json 2>/dev/null)
if [ -z "$DEP_JSON" ]; then
  echo "FAIL: Deployment safari not found in project-t230"
  FAIL=1
else
  IMAGE=$(echo "$DEP_JSON" | jq -r '.spec.template.spec.containers[0].image')
  [ "$IMAGE" == "httpd:2-alpine" ] && echo "PASS: Deployment uses image httpd:2-alpine" || { echo "FAIL: image=$IMAGE"; FAIL=1; }

  MOUNT_PATH=$(echo "$DEP_JSON" | jq -r '.spec.template.spec.containers[0].volumeMounts[]? | select(.mountPath=="/tmp/safari-data") | .mountPath')
  if [ "$MOUNT_PATH" == "/tmp/safari-data" ]; then
    echo "PASS: volume mounted at /tmp/safari-data"
    VOL_NAME=$(echo "$DEP_JSON" | jq -r '.spec.template.spec.containers[0].volumeMounts[] | select(.mountPath=="/tmp/safari-data") | .name')
    CLAIM=$(echo "$DEP_JSON" | jq -r --arg vn "$VOL_NAME" '.spec.template.spec.volumes[] | select(.name==$vn) | .persistentVolumeClaim.claimName // ""')
    [ "$CLAIM" == "safari-pvc" ] && echo "PASS: volume references PVC safari-pvc" || { echo "FAIL: volume references claim '$CLAIM'"; FAIL=1; }
  else
    echo "FAIL: no volumeMount at /tmp/safari-data found"
    FAIL=1
  fi

  READY=$(echo "$DEP_JSON" | jq -r '.status.readyReplicas // 0')
  [ "$READY" -ge 1 ] && echo "PASS: at least 1 replica ready" || { echo "FAIL: no ready replicas"; FAIL=1; }
fi

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED ===="
  exit 1
fi
