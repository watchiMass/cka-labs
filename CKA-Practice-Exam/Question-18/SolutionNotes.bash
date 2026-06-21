# Step 0: confirm the OOMKilled root cause
kubectl get pods -n patch-demo -l app=report-generator
POD=$(kubectl get pods -n patch-demo -l app=report-generator -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod "$POD" -n patch-demo | grep -A5 "Last State"
# Expect:
#   Last State:     Terminated
#     Reason:       OOMKilled

# Step 1: apply a strategic merge patch to raise the memory request/limit
kubectl patch deployment report-generator -n patch-demo --type='merge' -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "report-generator",
            "resources": {
              "requests": {
                "memory": "150Mi",
                "cpu": "50m"
              },
              "limits": {
                "memory": "300Mi",
                "cpu": "200m"
              }
            }
          }
        ]
      }
    }
  }
}'

# Step 2: watch the rollout
kubectl rollout status deployment report-generator -n patch-demo

# Step 3: confirm pods are stable
kubectl get pods -n patch-demo -l app=report-generator -w
# Let it run for ~60s and confirm RESTARTS does not increase further.

# Step 4: confirm the live object reflects the new limit
kubectl get deployment report-generator -n patch-demo \
  -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}'
echo
kubectl get deployment report-generator -n patch-demo \
  -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}'
echo
