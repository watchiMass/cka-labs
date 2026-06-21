#!/bin/bash
# setup-default-deny.sh
# Question 13 - Networking: Default-Deny NetworkPolicy with Namespace Selector
set -uo pipefail

echo "Setting up Question 13: Default-Deny NetworkPolicy..."

kubectl create namespace secure-zone --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace trusted-clients --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace untrusted-clients --dry-run=client -o yaml | kubectl apply -f -

kubectl label namespace trusted-clients access=allowed --overwrite
kubectl label namespace untrusted-clients access=denied --overwrite

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: secure-zone
spec:
  replicas: 2
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      containers:
      - name: secure-app
        image: nginx:1.27
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: secure-app
  namespace: secure-zone
spec:
  selector:
    app: secure-app
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: client
  namespace: trusted-clients
spec:
  replicas: 1
  selector:
    matchLabels:
      app: client
  template:
    metadata:
      labels:
        app: client
    spec:
      containers:
      - name: client
        image: busybox
        command: ["sleep", "infinity"]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: client
  namespace: untrusted-clients
spec:
  replicas: 1
  selector:
    matchLabels:
      app: client
  template:
    metadata:
      labels:
        app: client
    spec:
      containers:
      - name: client
        image: busybox
        command: ["sleep", "infinity"]
EOF

echo "[OK] Question 13 lab environment ready"
echo "NOTE: This task requires a CNI that enforces NetworkPolicy (e.g. Calico)."
