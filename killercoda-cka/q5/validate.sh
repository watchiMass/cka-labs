#!/bin/bash
FAIL=0

# 1. ConfigMap removed from cluster
if kubectl -n api-gateway-staging get configmap horizontal-scaling-config &>/dev/null || \
   kubectl -n api-gateway-prod get configmap horizontal-scaling-config &>/dev/null; then
  echo "FAIL: ConfigMap horizontal-scaling-config still exists in cluster"
  FAIL=1
else
  echo "PASS: ConfigMap horizontal-scaling-config removed from cluster"
fi

# Also check the kustomize source no longer generates it
if kubectl kustomize /opt/course/5/api-gateway/staging 2>/dev/null | grep -q "horizontal-scaling-config"; then
  echo "FAIL: kustomize staging output still contains horizontal-scaling-config"
  FAIL=1
else
  echo "PASS: kustomize staging output no longer contains horizontal-scaling-config"
fi

# 2/3. HPA staging
STAGING_HPA=$(kubectl -n api-gateway-staging get hpa api-gateway -o json 2>/dev/null)
if [ -z "$STAGING_HPA" ]; then
  echo "FAIL: HPA api-gateway not found in api-gateway-staging"
  FAIL=1
else
  MIN=$(echo "$STAGING_HPA" | jq -r '.spec.minReplicas')
  MAX=$(echo "$STAGING_HPA" | jq -r '.spec.maxReplicas')
  TARGET_DEP=$(echo "$STAGING_HPA" | jq -r '.spec.scaleTargetRef.name')
  CPU=$(echo "$STAGING_HPA" | jq -r '.spec.metrics[]? | select(.resource.name=="cpu") | .resource.target.averageUtilization' 2>/dev/null)
  if [ -z "$CPU" ]; then
    CPU=$(echo "$STAGING_HPA" | jq -r '.spec.targetCPUUtilizationPercentage' 2>/dev/null)
  fi

  [ "$MIN" == "2" ] && echo "PASS: staging HPA minReplicas=2" || { echo "FAIL: staging HPA minReplicas=$MIN, expected 2"; FAIL=1; }
  [ "$MAX" == "4" ] && echo "PASS: staging HPA maxReplicas=4" || { echo "FAIL: staging HPA maxReplicas=$MAX, expected 4"; FAIL=1; }
  [ "$TARGET_DEP" == "api-gateway" ] && echo "PASS: staging HPA targets Deployment api-gateway" || { echo "FAIL: staging HPA targets $TARGET_DEP"; FAIL=1; }
  [ "$CPU" == "50" ] && echo "PASS: staging HPA targets 50% CPU" || { echo "FAIL: staging HPA CPU target=$CPU, expected 50"; FAIL=1; }
fi

# 3. HPA prod max=6
PROD_HPA=$(kubectl -n api-gateway-prod get hpa api-gateway -o json 2>/dev/null)
if [ -z "$PROD_HPA" ]; then
  echo "FAIL: HPA api-gateway not found in api-gateway-prod"
  FAIL=1
else
  MIN=$(echo "$PROD_HPA" | jq -r '.spec.minReplicas')
  MAX=$(echo "$PROD_HPA" | jq -r '.spec.maxReplicas')
  [ "$MIN" == "2" ] && echo "PASS: prod HPA minReplicas=2" || { echo "FAIL: prod HPA minReplicas=$MIN, expected 2"; FAIL=1; }
  [ "$MAX" == "6" ] && echo "PASS: prod HPA maxReplicas=6" || { echo "FAIL: prod HPA maxReplicas=$MAX, expected 6"; FAIL=1; }
fi

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED ===="
  exit 1
fi
