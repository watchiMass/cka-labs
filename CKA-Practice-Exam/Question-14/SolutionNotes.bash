# Step 0: find the existing provisioner string used by the cluster
kubectl get storageclass -o yaml | grep -A1 "provisioner:"
# Example (kind / local-path-provisioner clusters):
#   provisioner: rancher.io/local-path
# Example (AWS EKS):
#   provisioner: ebs.csi.aws.com

# Step 1: create the StorageClass (substitute the real provisioner below)
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: expandable-storage
provisioner: rancher.io/local-path   # replace with your cluster's provisioner
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF

# Step 2: create the PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data-claim
  namespace: storage-demo
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: expandable-storage
  resources:
    requests:
      storage: 1Gi
EOF

# At this point, with WaitForFirstConsumer, the PVC will show STATUS=Pending
# until a Pod that uses it is scheduled. This is expected behavior.
kubectl get pvc app-data-claim -n storage-demo

# Step 3: create the consuming Pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: storage-test
  namespace: storage-demo
spec:
  containers:
  - name: storage-test
    image: nginx:1.27
    volumeMounts:
    - name: data
      mountPath: /usr/share/data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: app-data-claim
EOF

kubectl get pod storage-test -n storage-demo -w
kubectl get pvc app-data-claim -n storage-demo
# STATUS should now be Bound

# Step 4: expand the PVC live (edit or patch)
kubectl patch pvc app-data-claim -n storage-demo \
  --type merge -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'

# Step 5: verify the resize
kubectl get pvc app-data-claim -n storage-demo
kubectl describe pvc app-data-claim -n storage-demo
# Look for CAPACITY: 2Gi, and check conditions for
# FileSystemResizePending clearing once the kubelet finishes the resize.
