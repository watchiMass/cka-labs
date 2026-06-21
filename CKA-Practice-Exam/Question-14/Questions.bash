# Question 14 (Hard) — Storage: StorageClass, Dynamic Provisioning & Expansion
# Domain: Storage (10%)

# Scenario
# You must enable dynamic volume provisioning with the ability to expand
# volumes later without downtime, using the cluster's existing CSI
# provisioner (use whichever provisioner backs the cluster's default
# StorageClass, e.g. rancher.io/local-path, ebs.csi.aws.com, or similar —
# inspect with `kubectl get storageclass -o yaml` to find the correct
# provisioner string for this environment).

# Tasks
# 1. Create a StorageClass named "expandable-storage" using the cluster's
#    existing provisioner, with:
#    - allowVolumeExpansion: true
#    - reclaimPolicy: Delete
#    - volumeBindingMode: WaitForFirstConsumer
# 2. Create a PersistentVolumeClaim named "app-data-claim" in namespace
#    "storage-demo" requesting 1Gi using storageClassName
#    "expandable-storage" and accessMode ReadWriteOnce.
# 3. Create a Pod named "storage-test" in "storage-demo" that mounts
#    "app-data-claim" at /usr/share/data, using image "nginx:1.27", and
#    confirm the PVC binds (WaitForFirstConsumer means it stays Pending
#    until a consuming pod is scheduled).
# 4. Once Bound and the pod is Running, expand the PVC to 2Gi by editing
#    its spec.resources.requests.storage.
# 5. Confirm the PVC shows the new capacity (2Gi) and that a
#    FileSystemResizePending condition (if present) clears once the
#    kubelet completes the resize, or that
#    `kubectl get pvc app-data-claim -n storage-demo` directly reports
#    2Gi under CAPACITY.

# Constraints
# - Do not delete and recreate the PVC to "resize" it; perform a live
#   expansion via edit/patch.
# - Do not use a provisioner that doesn't support volume expansion if the
#   default one in this cluster doesn't support it — note that limitation
#   in your validation instead.

# Documentation Reference
# Concepts -> Storage -> Storage Classes
# https://kubernetes.io/docs/concepts/storage/storage-classes/
# Tasks -> Administer a Cluster -> Resizing a Persistent Volume using a File System
# https://kubernetes.io/docs/tasks/administer-cluster/resize-pvc/
