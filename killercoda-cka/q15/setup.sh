#!/bin/bash
set -e

kubectl create namespace project-snake --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-1
  namespace: project-snake
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend-1
  template:
    metadata:
      labels:
        app: backend-1
    spec:
      containers:
      - name: backend
        image: httpd:2-alpine
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db1-main
  namespace: project-snake
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db1-main
  template:
    metadata:
      labels:
        app: db1-main
    spec:
      containers:
      - name: db1
        image: httpd:2-alpine
        ports:
        - containerPort: 1111
---
apiVersion: v1
kind: Service
metadata:
  name: db1-main
  namespace: project-snake
spec:
  selector:
    app: db1-main
  ports:
  - port: 1111
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db2-main
  namespace: project-snake
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db2-main
  template:
    metadata:
      labels:
        app: db2-main
    spec:
      containers:
      - name: db2
        image: httpd:2-alpine
        ports:
        - containerPort: 2222
---
apiVersion: v1
kind: Service
metadata:
  name: db2-main
  namespace: project-snake
spec:
  selector:
    app: db2-main
  ports:
  - port: 2222
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: other-app
  namespace: project-snake
spec:
  replicas: 1
  selector:
    matchLabels:
      app: other-app
  template:
    metadata:
      labels:
        app: other-app
    spec:
      containers:
      - name: other
        image: httpd:2-alpine
        ports:
        - containerPort: 3333
---
apiVersion: v1
kind: Service
metadata:
  name: other-app
  namespace: project-snake
spec:
  selector:
    app: other-app
  ports:
  - port: 3333
EOF

echo "Setup complete."
echo "NOTE: NetworkPolicy enforcement requires a CNI that supports it (e.g. Calico, Cilium)."
echo "If your Killercoda scenario uses a CNI without NetworkPolicy support (e.g. plain flannel),"
echo "the policy will be accepted by the API but not actually enforced."
