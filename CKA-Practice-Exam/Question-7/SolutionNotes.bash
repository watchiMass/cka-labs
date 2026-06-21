# Step 1: create the low-priority PriorityClass
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 100
globalDefault: false
description: "Used for filler / best-effort workloads."
EOF

# Step 2: create the high-priority PriorityClass with preemption enabled
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority-critical
value: 1000000
globalDefault: false
preemptionPolicy: PreemptLowerPriority
description: "Used for business-critical workloads that may preempt others."
EOF

# Step 3: patch the filler Deployment to use low-priority
kubectl patch deployment filler -n priority-demo --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/priorityClassName","value":"low-priority"}]'

# Force a rollout so existing pods pick up the new PriorityClass
# (priorityClassName changes only apply to NEW pods, not running ones)
kubectl rollout restart deployment filler -n priority-demo
kubectl rollout status deployment filler -n priority-demo

# Step 4: create the critical-task pod requesting more CPU than is free
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: critical-task
  namespace: priority-demo
spec:
  priorityClassName: high-priority-critical
  containers:
  - name: critical-task
    image: nginx:1.27
    resources:
      requests:
        cpu: "1500m"
      limits:
        cpu: "1500m"
EOF

# Step 5: observe scheduling and preemption
kubectl get pod critical-task -n priority-demo -w
kubectl get events -n priority-demo --sort-by='.lastTimestamp' | grep -i preempt
kubectl get pods -n priority-demo -o wide
