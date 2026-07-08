#!/bin/bash
FAIL=0
NS=project-hamster
SA_USER="system:serviceaccount:${NS}:processor"

if kubectl -n $NS get serviceaccount processor &>/dev/null; then
  echo "PASS: ServiceAccount processor exists"
else
  echo "FAIL: ServiceAccount processor not found"
  FAIL=1
fi

if kubectl -n $NS get role processor &>/dev/null; then
  echo "PASS: Role processor exists"
else
  echo "FAIL: Role processor not found"
  FAIL=1
fi

if kubectl -n $NS get rolebinding processor &>/dev/null; then
  echo "PASS: RoleBinding processor exists"
else
  echo "FAIL: RoleBinding processor not found"
  FAIL=1
fi

# Permission checks
check_perm() {
  local verb=$1
  local resource=$2
  local expect=$3
  RESULT=$(kubectl -n $NS auth can-i "$verb" "$resource" --as="$SA_USER" 2>/dev/null)
  if [ "$RESULT" == "$expect" ]; then
    echo "PASS: can-i $verb $resource = $RESULT (expected)"
  else
    echo "FAIL: can-i $verb $resource = $RESULT, expected $expect"
    FAIL=1
  fi
}

check_perm create secrets yes
check_perm create configmaps yes
check_perm get secrets no
check_perm list secrets no
check_perm delete secrets no
check_perm create pods no

# Verify no cluster-wide scope leakage
CLUSTER_CHECK=$(kubectl auth can-i create secrets --as="$SA_USER" -n default 2>/dev/null)
if [ "$CLUSTER_CHECK" == "no" ]; then
  echo "PASS: permissions correctly scoped to project-hamster namespace only"
else
  echo "FAIL: SA has create secrets permission outside project-hamster (used ClusterRole/ClusterRoleBinding?)"
  FAIL=1
fi

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED ===="
  exit 1
fi
