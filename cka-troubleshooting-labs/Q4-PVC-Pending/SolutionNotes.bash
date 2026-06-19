# Solution Notes — Question 4: PVC Pending
#
# ─── TASK 1: database-pvc ────────────────────────────────────────────────────

# Diagnosis:
kubectl describe pvc database-pvc -n q4-storage
# Events: "storageclass.storage.k8s.io "ultra-fast-nvme" not found"

kubectl get storageclass
# Available StorageClasses: fast-ssd, local-path (or similar)
# "ultra-fast-nvme" does not exist

# Fix: delete the PVC and recreate it with the correct StorageClass
# (PVCs cannot be edited once created for storageClassName)
kubectl delete pvc database-pvc -n q4-storage

kubectl apply -n q4-storage -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-pvc
  namespace: q4-storage
spec:
  storageClassName: fast-ssd
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# The database-pod will restart automatically and bind the PVC
kubectl get pod database-pod -n q4-storage
# Note: pod may need to be deleted/recreated if it doesn't recover:
kubectl delete pod database-pod -n q4-storage
kubectl apply -n q4-storage -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: database-pod
  namespace: q4-storage
spec:
  containers:
  - name: db
    image: nginx:1.25
    volumeMounts:
    - name: data
      mountPath: /var/lib/data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: database-pvc
EOF

# ─── TASK 2: shared-pvc ──────────────────────────────────────────────────────

# Diagnosis:
kubectl describe pvc shared-pvc -n q4-storage
# Events: "waiting for a volume to be created" or "no persistent volumes available"
# The local-path provisioner only supports ReadWriteOnce

kubectl describe storageclass fast-ssd
# Provisioner: rancher.io/local-path → single node only → no ReadWriteMany

# Fix: delete and recreate PVC with ReadWriteOnce
kubectl delete pvc shared-pvc -n q4-storage

kubectl apply -n q4-storage -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-pvc
  namespace: q4-storage
spec:
  storageClassName: fast-ssd
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF

# With volumeBindingMode: WaitForFirstConsumer, the PVC binds when first pod is scheduled
kubectl rollout restart deployment/shared-app -n q4-storage

# Verify:
kubectl get pvc -n q4-storage
# Both PVCs should show Bound

kubectl get pods -n q4-storage
# database-pod: Running, shared-app pods: Running
