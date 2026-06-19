#!/bin/bash
# Lab Setup for Question 4 - PVC Pending Troubleshooting
set -e

echo "Creating namespace..."
kubectl create namespace q4-storage --dry-run=client -o yaml | kubectl apply -f -

echo "Creating a valid StorageClass for reference..."
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF

echo "Creating a broken PVC (references non-existent StorageClass)..."
kubectl apply -n q4-storage -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-pvc
  namespace: q4-storage
spec:
  storageClassName: ultra-fast-nvme
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

echo "Deploying database pod that depends on the broken PVC..."
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

echo "Creating a second broken PVC (wrong accessMode for multi-node)..."
kubectl apply -n q4-storage -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-pvc
  namespace: q4-storage
spec:
  storageClassName: fast-ssd
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 500Mi
EOF

echo "Deploying app that needs the shared PVC..."
kubectl apply -n q4-storage -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shared-app
  namespace: q4-storage
spec:
  replicas: 2
  selector:
    matchLabels:
      app: shared-app
  template:
    metadata:
      labels:
        app: shared-app
    spec:
      containers:
      - name: app
        image: nginx:1.25
        volumeMounts:
        - name: shared-data
          mountPath: /data
      volumes:
      - name: shared-data
        persistentVolumeClaim:
          claimName: shared-pvc
EOF

echo "[OK] Lab Q4 setup complete."
echo ""
echo "Your tasks:"
echo "  1. PVC 'database-pvc' is in Pending state — find and fix the issue"
echo "     so that 'database-pod' can start Running"
echo "  2. PVC 'shared-pvc' is also Pending — identify the issue"
echo "     and fix it so 'shared-app' replicas start Running"
echo "     (Hint: check what the StorageClass 'fast-ssd' actually supports)"
