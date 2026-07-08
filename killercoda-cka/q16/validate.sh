#!/bin/bash
FAIL=0

if [ ! -f /opt/course/16/coredns_backup.yaml ]; then
  echo "FAIL: /opt/course/16/coredns_backup.yaml does not exist"
  FAIL=1
else
  if grep -q "kind: ConfigMap" /opt/course/16/coredns_backup.yaml && grep -q "Corefile" /opt/course/16/coredns_backup.yaml; then
    echo "PASS: backup file looks like a valid coredns ConfigMap backup"
  else
    echo "FAIL: backup file does not look like a valid coredns ConfigMap"
    FAIL=1
  fi
fi

COREFILE=$(kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' 2>/dev/null)
if echo "$COREFILE" | grep -qE "custom-domain"; then
  echo "PASS: Corefile contains custom-domain zone"
else
  echo "FAIL: Corefile does not mention custom-domain"
  FAIL=1
fi

if echo "$COREFILE" | grep -qE "cluster\.local"; then
  echo "PASS: Corefile still contains cluster.local (not removed)"
else
  echo "FAIL: cluster.local zone seems to have been removed"
  FAIL=1
fi

# Functional test
echo "Running functional DNS test..."
kubectl run dns-test-16 --image=busybox:1 --restart=Never --command -- sleep 3600 &>/dev/null
kubectl wait --for=condition=ready pod/dns-test-16 --timeout=30s &>/dev/null

RES_LOCAL=$(kubectl exec dns-test-16 -- nslookup kubernetes.default.svc.cluster.local 2>/dev/null | grep -c "Address")
RES_CUSTOM=$(kubectl exec dns-test-16 -- nslookup kubernetes.default.svc.custom-domain 2>/dev/null | grep -c "Address")

if [ "$RES_LOCAL" -ge 1 ]; then
  echo "PASS: nslookup kubernetes.default.svc.cluster.local resolves"
else
  echo "FAIL: nslookup kubernetes.default.svc.cluster.local did not resolve"
  FAIL=1
fi

if [ "$RES_CUSTOM" -ge 1 ]; then
  echo "PASS: nslookup kubernetes.default.svc.custom-domain resolves"
else
  echo "FAIL: nslookup kubernetes.default.svc.custom-domain did not resolve"
  FAIL=1
fi

kubectl delete pod dns-test-16 --ignore-not-found=true --wait=false &>/dev/null

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED ===="
  exit 1
fi
