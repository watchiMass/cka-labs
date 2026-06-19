#!/bin/bash
# Validation script for Question 1 - Pod CrashLoopBackOff Troubleshooting
set -uo pipefail

PASS=0
FAIL=0
TOTAL=0

check() {
  local description="$1"
  shift
  TOTAL=$((TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    echo "  PASS: $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $description"
    FAIL=$((FAIL + 1))
  fi
}

echo "============================================"
echo " Validating Question 1: Pod Troubleshooting"
echo "============================================"
echo ""
echo "--- Task 1: api-server-pod ---"

check "Pod 'api-server-pod' exists in namespace q1-crashloop" \
  bash -c 'kubectl get pod api-server-pod -n q1-crashloop >/dev/null 2>&1'

check "Pod 'api-server-pod' is in Running phase" \
  bash -c '
    PHASE=$(kubectl get pod api-server-pod -n q1-crashloop -o jsonpath="{.status.phase}" 2>/dev/null)
    [[ "$PHASE" == "Running" ]]
  '

check "Pod 'api-server-pod' is Ready (1/1)" \
  bash -c '
    READY=$(kubectl get pod api-server-pod -n q1-crashloop -o jsonpath="{.status.containerStatuses[0].ready}" 2>/dev/null)
    [[ "$READY" == "true" ]]
  '

check "Pod 'api-server-pod' uses nginx image" \
  bash -c '
    IMAGE=$(kubectl get pod api-server-pod -n q1-crashloop -o jsonpath="{.spec.containers[0].image}" 2>/dev/null)
    [[ "$IMAGE" == *"nginx"* ]]
  '

echo ""
echo "--- Task 2: worker-deployment ---"

check "Deployment 'worker-deployment' exists in namespace q1-crashloop" \
  bash -c 'kubectl get deployment worker-deployment -n q1-crashloop >/dev/null 2>&1'

check "Deployment 'worker-deployment' has 2 desired replicas" \
  bash -c '
    REPLICAS=$(kubectl get deployment worker-deployment -n q1-crashloop -o jsonpath="{.spec.replicas}" 2>/dev/null)
    [[ "$REPLICAS" == "2" ]]
  '

check "Deployment 'worker-deployment' has 2 ready replicas" \
  bash -c '
    READY=$(kubectl get deployment worker-deployment -n q1-crashloop -o jsonpath="{.status.readyReplicas}" 2>/dev/null)
    [[ "$READY" == "2" ]]
  '

check "Deployment 'worker-deployment' uses a valid busybox image" \
  bash -c '
    IMAGE=$(kubectl get deployment worker-deployment -n q1-crashloop -o jsonpath="{.spec.template.spec.containers[0].image}" 2>/dev/null)
    [[ "$IMAGE" == *"busybox"* ]] && [[ "$IMAGE" != "busybox:9.9.9" ]]
  '

echo ""
echo "============================================"
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
echo "============================================"

exit $FAIL
