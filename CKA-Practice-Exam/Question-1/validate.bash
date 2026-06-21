#!/bin/bash
# Validation script for Question 1 - etcd Backup & Restore with TLS
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

echo "==========================================="
echo " Validating Question 1: etcd Backup/Restore"
echo "==========================================="

# 1. Snapshot file exists
check "Snapshot file exists at /opt/backups/etcd-snapshot.db" \
  bash -c '[[ -f /opt/backups/etcd-snapshot.db ]]'

# 2. Snapshot file is non-trivial in size (sanity check it's a real db)
check "Snapshot file is non-empty (> 20KB)" \
  bash -c '[[ $(stat -c%s /opt/backups/etcd-snapshot.db 2>/dev/null || echo 0) -gt 20000 ]]'

# 3. Restored data directory exists
check "Restored data directory /var/lib/etcd-from-backup exists" \
  bash -c '[[ -d /var/lib/etcd-from-backup ]]'

# 4. etcd static pod manifest points at the restored data dir
check "etcd manifest hostPath updated to /var/lib/etcd-from-backup" \
  bash -c 'grep -q "/var/lib/etcd-from-backup" /etc/kubernetes/manifests/etcd.yaml'

# 5. etcd pod is Running
check "etcd static pod is Running in kube-system" \
  bash -c '
    STATUS=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath="{.items[0].status.phase}" 2>/dev/null)
    [[ "$STATUS" == "Running" ]]
  '

# 6. Cluster API is responsive after restore
check "API server responds (kubectl get ns)" \
  kubectl get namespaces

# 7. The marker ConfigMap was restored (proves restore actually rolled back state)
check "ConfigMap 'pre-backup-marker' exists again in etcd-demo (restore verified)" \
  bash -c '
    VAL=$(kubectl get configmap pre-backup-marker -n etcd-demo -o jsonpath="{.data.marker}" 2>/dev/null)
    [[ "$VAL" == "this-must-survive-the-restore" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
