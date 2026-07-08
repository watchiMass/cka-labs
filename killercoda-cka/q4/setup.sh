#!/bin/bash
set -e

mkdir -p /opt/course/4
kubectl create namespace project-c13 --dry-run=client -o yaml | kubectl apply -f -

# Pod 1: BestEffort (no requests/limits) -> evicted first
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: c13-best-effort
  namespace: project-c13
  labels:
    app: c13
spec:
  containers:
  - name: c13
    image: httpd:2-alpine
EOF

# Pod 2: Burstable (requests < limits)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: c13-burstable
  namespace: project-c13
  labels:
    app: c13
spec:
  containers:
  - name: c13
    image: httpd:2-alpine
    resources:
      requests:
        cpu: "50m"
        memory: "50Mi"
      limits:
        cpu: "100m"
        memory: "100Mi"
EOF

# Pod 3: Guaranteed (requests == limits)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: c13-guaranteed
  namespace: project-c13
  labels:
    app: c13
spec:
  containers:
  - name: c13
    image: httpd:2-alpine
    resources:
      requests:
        cpu: "100m"
        memory: "100Mi"
      limits:
        cpu: "100m"
        memory: "100Mi"
EOF

# Pod 4: another Burstable (only requests set, no limits)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: c13-burstable2
  namespace: project-c13
  labels:
    app: c13
spec:
  containers:
  - name: c13
    image: httpd:2-alpine
    resources:
      requests:
        cpu: "50m"
        memory: "50Mi"
EOF

echo "Setup complete."
