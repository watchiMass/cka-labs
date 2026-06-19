# Solution Notes — Question 5: Deployment Rollout & RBAC
#
# ─── TASK 1: memory-hog OOMKilled ────────────────────────────────────────────

# Diagnosis:
kubectl describe pod -l app=memory-hog -n q5-rollout | grep -E "OOMKilled|Reason|Limits"
# State: Terminated  Reason: OOMKilled
# Limits: memory: 4Mi  ← way too low for nginx

# Fix: increase memory limit
kubectl patch deployment memory-hog -n q5-rollout --type='json' -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/resources/requests/memory","value":"32Mi"},
  {"op":"replace","path":"/spec/template/spec/containers/0/resources/limits/memory","value":"64Mi"}
]'

# Or: kubectl edit deployment memory-hog -n q5-rollout

# Verify:
kubectl rollout status deployment/memory-hog -n q5-rollout
kubectl get pods -n q5-rollout -l app=memory-hog
# Expected: 2/2 Running, no restarts

# ─── TASK 2: rolling-app stuck rollout ───────────────────────────────────────

# Diagnosis:
kubectl rollout status deployment/rolling-app -n q5-rollout
# "Waiting for rollout to finish: 0 out of 3 new replicas have been updated"

# Why it's stuck — TWO issues:
# Issue 1: strategy maxSurge=0 AND maxUnavailable=0 → impossible (no room to create new pods,
#          no room to kill old ones → deadlock)
kubectl get deployment rolling-app -n q5-rollout -o yaml | grep -A5 rollingUpdate

# Issue 2: new image nginx:does-not-exist → ImagePullBackOff on any new pod
kubectl get pods -n q5-rollout -l app=rolling-app
# Some pods show ImagePullBackOff

# Fix option A: rollback (recommended — fastest in exam)
kubectl rollout undo deployment/rolling-app -n q5-rollout

# Fix option B: fix strategy AND image together
kubectl patch deployment rolling-app -n q5-rollout --type='json' -p='[
  {"op":"replace","path":"/spec/strategy/rollingUpdate/maxUnavailable","value":1},
  {"op":"replace","path":"/spec/template/spec/containers/0/image","value":"nginx:1.25"}
]'

# Verify:
kubectl rollout status deployment/rolling-app -n q5-rollout
kubectl get pods -n q5-rollout -l app=rolling-app
# Expected: 3/3 Running with nginx:1.25

# ─── TASK 3: rbac-app Forbidden ──────────────────────────────────────────────

# Diagnosis:
kubectl logs -l app=rbac-app -n q5-rollout
# Error from server (Forbidden): pods is forbidden:
# User "system:serviceaccount:q5-rollout:pod-reader-sa" cannot list resource "pods"

# Fix: create a Role and RoleBinding
kubectl apply -n q5-rollout -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader-role
  namespace: q5-rollout
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
EOF

kubectl apply -n q5-rollout -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: q5-rollout
subjects:
- kind: ServiceAccount
  name: pod-reader-sa
  namespace: q5-rollout
roleRef:
  kind: Role
  apiGroupd: rbac.authorization.k8s.io
  name: pod-reader-role
EOF

# Verify (wait ~10s for the next loop iteration):
kubectl logs -l app=rbac-app -n q5-rollout --tail=5
# Expected: NAME   READY   STATUS   ...  (pod listing output, no Forbidden)

# Or test directly:
kubectl auth can-i list pods -n q5-rollout --as=system:serviceaccount:q5-rollout:pod-reader-sa
# Expected: yes
