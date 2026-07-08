#!/bin/bash
FAIL=0

# 1. Namespace exists
if kubectl get namespace cert-manager &>/dev/null; then
  echo "PASS: Namespace cert-manager exists"
else
  echo "FAIL: Namespace cert-manager does not exist"
  FAIL=1
fi

# 2. Helm release exists in namespace
if helm list -n cert-manager 2>/dev/null | grep -q "^cert-manager"; then
  echo "PASS: Helm release cert-manager found in namespace cert-manager"
else
  echo "FAIL: Helm release cert-manager not found in namespace cert-manager"
  FAIL=1
fi

# Check crds installed (via CRD existence, since crds.enabled=true)
if kubectl get crd clusterissuers.cert-manager.io &>/dev/null; then
  echo "PASS: cert-manager CRDs installed (clusterissuers.cert-manager.io found)"
else
  echo "FAIL: cert-manager CRDs not found - was crds.enabled=true set?"
  FAIL=1
fi

# cert-manager pods running
RUNNING=$(kubectl get pods -n cert-manager --no-headers 2>/dev/null | grep -c "Running")
if [ "$RUNNING" -ge 3 ]; then
  echo "PASS: cert-manager pods are running ($RUNNING running)"
else
  echo "FAIL: expected at least 3 running cert-manager pods, got $RUNNING"
  FAIL=1
fi

# 3+4. ClusterIssuer resource created with crlDistributionPoints
CI_JSON=$(kubectl get clusterissuer -o json 2>/dev/null)
if [ -z "$CI_JSON" ] || [ "$(echo "$CI_JSON" | jq '.items | length')" -eq 0 ]; then
  echo "FAIL: no ClusterIssuer resource found in the cluster"
  FAIL=1
else
  MATCH=$(echo "$CI_JSON" | jq -r '.items[] | select(.spec.selfSigned.crlDistributionPoints != null) | .metadata.name')
  if [ -n "$MATCH" ]; then
    echo "PASS: ClusterIssuer '$MATCH' found with selfSigned.crlDistributionPoints set"
    VALUE=$(echo "$CI_JSON" | jq -r --arg n "$MATCH" '.items[] | select(.metadata.name==$n) | .spec.selfSigned.crlDistributionPoints[0]')
    if [ "$VALUE" == "http://example.com/crl" ]; then
      echo "PASS: crlDistributionPoints value is correct"
    else
      echo "FAIL: crlDistributionPoints value incorrect, got '$VALUE'"
      FAIL=1
    fi
  else
    echo "FAIL: no ClusterIssuer with selfSigned.crlDistributionPoints found"
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
