# Step 0: identify the tainted/labeled node
kubectl get nodes -o json | jq -r '.items[] | select(.spec.taints != null) | .metadata.name'
kubectl get nodes -l hardware=gpu

# Step 1: create the gpu-workload Deployment with both toleration AND affinity
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gpu-workload
  namespace: scheduling-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: gpu-workload
  template:
    metadata:
      labels:
        app: gpu-workload
    spec:
      tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "gpu-workloads"
        effect: "NoSchedule"
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: hardware
                operator: In
                values:
                - gpu
      containers:
      - name: gpu-workload
        image: nginx:1.27
EOF

# Step 2: verify scheduling
kubectl get pods -n scheduling-demo -l app=gpu-workload -o wide
kubectl get pods -n scheduling-demo -l app=generic-app -o wide

# All gpu-workload pods should show the same NODE (the tainted one).
# All generic-app pods should show a NODE that is NOT the tainted one
# (this was already true before this task, since generic-app has no
# toleration for the NoSchedule taint).
