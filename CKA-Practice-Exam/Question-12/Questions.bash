# Question 12 (Hard) — Services & Networking: Ingress with TLS & Path Routing
# Domain: Services & Networking (20%)

# Scenario
# Namespace "ingress-demo" runs two independent applications, "shop-app"
# and "blog-app", each backed by its own Service on port 80. A TLS secret
# "shop-tls-secret" has already been created. You must expose both
# applications under a single host via path-based routing, with TLS
# termination for the host.

# Tasks
# 1. Create an Ingress named "shop-ingress" in namespace "ingress-demo"
#    using ingressClassName "nginx".
# 2. Configure a TLS block for host "shop.example.com" referencing
#    secretName "shop-tls-secret".
# 3. Configure routing rules for host "shop.example.com":
#    - path "/shop" (pathType Prefix) routes to Service "shop-app" port 80
#    - path "/blog" (pathType Prefix) routes to Service "blog-app" port 80
# 4. Add the annotation
#    nginx.ingress.kubernetes.io/rewrite-target: /
#    so requests forwarded to the backends have the path prefix stripped.
# 5. Confirm the Ingress object shows the correct host, paths, and TLS
#    configuration with `kubectl describe ingress shop-ingress -n
#    ingress-demo`.
# 6. Test (if an ingress controller with a reachable address is present)
#    that curling https://shop.example.com/shop and
#    https://shop.example.com/blog (with --resolve and -k flags as needed
#    for the self-signed cert and missing DNS) reach their respective
#    backends.

# Constraints
# - Use networking.k8s.io/v1 Ingress.
# - Do not create a LoadBalancer Service directly; routing must go
#   through the Ingress resource.

# Documentation Reference
# Concepts -> Services, Load Balancing, and Networking -> Ingress
# https://kubernetes.io/docs/concepts/services-networking/ingress/
