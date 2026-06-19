# Question 4 — PVC Pending Troubleshooting
#
# Context:
#   Two PersistentVolumeClaims in namespace 'q4-storage' are stuck in Pending.
#   The pods that depend on them cannot start.
#   The cluster has a StorageClass named 'fast-ssd' available.
#
# Task 1 — database-pvc / database-pod:
#   The PVC 'database-pvc' is Pending and 'database-pod' is also stuck.
#   Find the issue in the PVC and fix it.
#   After fixing, 'database-pod' should be Running.
#   Storage size must remain 1Gi, accessMode ReadWriteOnce.
#
# Task 2 — shared-pvc / shared-app:
#   The PVC 'shared-pvc' is Pending and 'shared-app' replicas cannot start.
#   The local-path StorageClass does not support ReadWriteMany.
#   Fix the PVC (and deployment if needed) so the 2 replicas can run.
#   Acceptable fix: change accessMode to ReadWriteOnce and ensure only
#   one pod mounts the volume at a time, OR use a compatible approach.
#   Simplest fix: change accessMode to ReadWriteOnce.
#
# Investigation commands:
#   kubectl get pvc -n q4-storage
#   kubectl describe pvc database-pvc -n q4-storage
#   kubectl describe pvc shared-pvc -n q4-storage
#   kubectl get storageclass
#   kubectl describe storageclass fast-ssd
#   kubectl get events -n q4-storage --sort-by='.lastTimestamp'
