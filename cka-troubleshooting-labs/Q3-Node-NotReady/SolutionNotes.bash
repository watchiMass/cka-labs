# Solution Notes — Question 3: Node Scheduling Troubleshooting
#
# ─── TASK 1: critical-app pods Pending ───────────────────────────────────────

# Step 1: Check pod events
kubectl describe pod -l app=critical-app -n q3-scheduling | grep -A5 Events
# "0/2 nodes are available: 1 node(s) had untolerated taint {maintenance: true}"
# "1 node(s) were unschedulable"

# Step 2: Find the affected node
kubectl get nodes
# NAME            STATUS                     ROLES   AGE
# controlplane    Ready                      master  ...
# worker1         Ready,SchedulingDisabled   <none>  ...   ← cordoned!

# Step 3: Check taints
kubectl describe node worker1 | grep Taints
# Taints: maintenance=true:NoSchedule

# Fix: remove the taint AND uncordon the node
WORKER=$(cat /tmp/q3-worker1-name.txt 2>/dev/null || kubectl get nodes --no-headers | grep -v 'control-plane\|master' | awk 'NR==1{print $1}')

kubectl taint node "$WORKER" maintenance=true:NoSchedule-
kubectl uncordon "$WORKER"

# Verify:
kubectl get nodes
# SchedulingDisabled gone

kubectl get pods -n q3-scheduling -l app=critical-app
# All 3 pods should be Running

# ─── TASK 2: gpu-workload pod Pending ────────────────────────────────────────

# Step 1: Describe the pod
kubectl describe pod gpu-workload -n q3-scheduling | grep -A10 Events
# "didn't match Pod's node affinity/selector"
# or: "0/2 nodes are available: 2 node(s) didn't match node selector"

# Step 2: Check the pod spec
kubectl get pod gpu-workload -n q3-scheduling -o yaml | grep -A5 nodeSelector
# nodeSelector:
#   accelerator: nvidia-tesla-v100   ← no node has this label

# Fix: Remove the nodeSelector from the pod
# Pods are immutable → delete and recreate without the nodeSelector:
kubectl delete pod gpu-workload -n q3-scheduling

kubectl apply -n q3-scheduling -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: gpu-workload
  namespace: q3-scheduling
spec:
  containers:
  - name: compute
    image: busybox:1.36
    command: ["sleep", "3600"]
    resources:
      requests:
        cpu: "50m"
        memory: "32Mi"
EOF

# Verify:
kubectl get pod gpu-workload -n q3-scheduling
# Expected: Running
