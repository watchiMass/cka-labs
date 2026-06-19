#!/bin/bash
# Validation script for Question 5 - Deployment Rollout & RBAC
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
echo " Validating Question 5: Rollout & RBAC"
echo "============================================"
echo ""
echo "--- Task 1: memory-hog ---"

check "Deployment 'memory-hog' has 2 ready replicas" \
  bash -c '
    R=$(kubectl get deployment memory-hog -n q5-rollout -o jsonpath="{.status.readyReplicas}" 2>/dev/null)
    [[ "$R" == "2" ]]
  '

check "memory-hog memory limit is at least 32Mi" \
  bash -c '
    LIMIT=$(kubectl get deployment memory-hog -n q5-rollout \
      -o jsonpath="{.spec.template.spec.containers[0].resources.limits.memory}" 2>/dev/null)
    # Convert Mi to number for comparison
    NUM=$(echo "$LIMIT" | sed "s/Mi//")
    [[ "${NUM:-0}" -ge 32 ]]
  '

check "No memory-hog pod is in OOMKilled state" \
  bash -c '
    COUNT=$(kubectl get pods -n q5-rollout -l app=memory-hog -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
count = 0
for pod in data[\"items\"]:
    for cs in pod.get(\"status\", {}).get(\"containerStatuses\", []):
        last = cs.get(\"lastState\", {}).get(\"terminated\", {})
        if last.get(\"reason\") == \"OOMKilled\":
            count += 1
print(count)
")
    [[ "${COUNT:-0}" -eq 0 ]]
  '

echo ""
echo "--- Task 2: rolling-app ---"

check "Deployment 'rolling-app' has 3 ready replicas" \
  bash -c '
    R=$(kubectl get deployment rolling-app -n q5-rollout -o jsonpath="{.status.readyReplicas}" 2>/dev/null)
    [[ "$R" == "3" ]]
  '

check "rolling-app uses a valid image (not nginx:does-not-exist)" \
  bash -c '
    IMG=$(kubectl get deployment rolling-app -n q5-rollout \
      -o jsonpath="{.spec.template.spec.containers[0].image}" 2>/dev/null)
    [[ "$IMG" != "nginx:does-not-exist" ]]
  '

check "rolling-app rollout strategy is not deadlocked (maxSurge + maxUnavailable not both 0)" \
  bash -c '
    kubectl get deployment rolling-app -n q5-rollout -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
strategy = data[\"spec\"].get(\"strategy\", {})
ru = strategy.get(\"rollingUpdate\", {})
surge = ru.get(\"maxSurge\", 1)
unavail = ru.get(\"maxUnavailable\", 1)
# Both 0 = deadlock
if str(surge) == \"0\" and str(unavail) == \"0\":
    sys.exit(1)
sys.exit(0)
"'

echo ""
echo "--- Task 3: rbac-app ---"

check "Role 'pod-reader-role' exists in namespace q5-rollout" \
  bash -c 'kubectl get role pod-reader-role -n q5-rollout >/dev/null 2>&1'

check "Role allows listing pods" \
  bash -c '
    kubectl get role pod-reader-role -n q5-rollout -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rule in data.get(\"rules\", []):
    if \"pods\" in rule.get(\"resources\", []):
        if \"list\" in rule.get(\"verbs\", []) or \"*\" in rule.get(\"verbs\", []):
            sys.exit(0)
sys.exit(1)
"'

check "RoleBinding exists for pod-reader-sa" \
  bash -c '
    kubectl get rolebinding -n q5-rollout -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rb in data[\"items\"]:
    for subj in rb.get(\"subjects\", []):
        if subj.get(\"name\") == \"pod-reader-sa\" and subj.get(\"kind\") == \"ServiceAccount\":
            sys.exit(0)
sys.exit(1)
"'

check "ServiceAccount pod-reader-sa can list pods in q5-rollout" \
  bash -c '
    RESULT=$(kubectl auth can-i list pods -n q5-rollout \
      --as=system:serviceaccount:q5-rollout:pod-reader-sa 2>/dev/null)
    [[ "$RESULT" == "yes" ]]
  '

echo ""
echo "============================================"
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
echo "============================================"

exit $FAIL
