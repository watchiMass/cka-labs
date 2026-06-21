# Question 11 (Hard) — Services & Networking: Gateway API HTTPRoute
# Domain: Services & Networking (20%)

# Scenario
# The Gateway API CRDs are installed in the cluster, along with a
# GatewayClass named "demo-gateway-class" provided by the cluster's
# Gateway controller. You must expose the "store-backend" Service in
# namespace "gw-demo" via the Gateway API instead of a legacy Ingress.

# Tasks
# 1. Create a Gateway named "demo-gateway" in namespace "gw-demo" that:
#    - uses gatewayClassName "demo-gateway-class"
#    - defines one listener named "http" on port 80, protocol HTTP,
#      with allowedRoutes restricted to the same namespace ("Same")
# 2. Create an HTTPRoute named "store-route" in namespace "gw-demo" that:
#    - has parentRefs pointing at the "demo-gateway" Gateway
#    - matches path prefix "/store"
#    - rewrites/forwards traffic to backendRef "store-backend" on port 80
# 3. Confirm the Gateway resource reports a Programmed/Accepted condition
#    of True (assuming a controller is reconciling it).
# 4. Confirm the HTTPRoute resource shows a ResolvedRefs condition of
#    True, meaning its backendRef was found successfully.

# Constraints
# - Use gateway.networking.k8s.io/v1 for both Gateway and HTTPRoute.
# - Do not create a classic networking.k8s.io/v1 Ingress for this task;
#   Gateway API only.

# Documentation Reference
# Concepts -> Services, Load Balancing, and Networking -> Gateway API
# https://kubernetes.io/docs/concepts/services-networking/gateway/
