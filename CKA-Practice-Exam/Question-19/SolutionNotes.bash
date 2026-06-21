# Step 0: identify the highmem node and its allocatable resources
HIGHMEM_NODE=$(kubectl get nodes -l pool=highmem -o jsonpath='{.items[0].metadata.name}')
echo "Highmem node: $HIGHMEM_NODE"
kubectl describe node "$HIGHMEM_NODE" | grep -A5 "Allocatable:"
# Example output:
#   Allocatable:
#     cpu:     2
#     memory:  3850000Ki
#
# Convert memory: 3850000Ki / 1024 ≈ 3760Mi
# CPU: 2 cores = 2000m

# Step 1: scale down before editing
kubectl scale deployment analytics-worker -n alloc-v2-demo --replicas=0

# Step 2: compute the even split across 4 replicas
#   CPU:    2000m / 4 = 500m per pod
#   Memory: 3760Mi / 4 = 940Mi per pod
#
# Subtract ~10% headroom for requests:
#   CPU requests:    500m * 0.9 ≈ 450m
#   Memory requests: 940Mi * 0.9 ≈ 846Mi
# Limits at/near the full even split:
#   CPU limits:    500m
#   Memory limits: 940Mi

# Step 3: edit the deployment with resources, nodeSelector, and anti-affinity
kubectl patch deployment analytics-worker -n alloc-v2-demo --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/nodeSelector",
    "value": {"pool": "highmem"}
  },
  {
    "op": "add",
    "path": "/spec/template/spec/affinity",
    "value": {
      "podAntiAffinity": {
        "preferredDuringSchedulingIgnoredDuringExecution": [
          {
            "weight": 100,
            "podAffinityTerm": {
              "labelSelector": {
                "matchLabels": {"app": "analytics-worker"}
              },
              "topologyKey": "kubernetes.io/hostname"
            }
          }
        ]
      }
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/resources",
    "value": {
      "requests": {"cpu": "450m", "memory": "846Mi"},
      "limits": {"cpu": "500m", "memory": "940Mi"}
    }
  }
]'

# Step 4: scale back up
kubectl scale deployment analytics-worker -n alloc-v2-demo --replicas=4
kubectl rollout status deployment analytics-worker -n alloc-v2-demo

# Step 5: verify placement and resources
kubectl get pods -n alloc-v2-demo -l app=analytics-worker -o wide
kubectl get deployment analytics-worker -n alloc-v2-demo -o jsonpath='{.spec.template.spec.containers[0].resources}'
echo
