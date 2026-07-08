# Question 13 | Gateway Api Ingress

Difficulty: Hard

The team from Project r500 wants to replace their Ingress (networking.k8s.io) with a Gateway Api (gateway.networking.k8s.io) solution. The old Ingress is available at `/opt/course/13/ingress.yaml`.

Perform the following in Namespace `project-r500` and for the already existing Gateway:

1. Create a new HTTPRoute named `traffic-director` which replicates the routes from the old Ingress
2. Extend the new HTTPRoute with path `/auto` which forwards to mobile backend if the User-Agent is exactly `mobile` and to desktop backend otherwise

The existing Gateway is reachable at `http://r500.gateway:30080` which means your implementation should work for these commands:

```
curl r500.gateway:30080/desktop
curl r500.gateway:30080/mobile
curl r500.gateway:30080/auto -H "User-Agent: mobile"
curl r500.gateway:30080/auto
```

<details><summary>Need a hint?</summary>

- Use `matches.headers` with `type: Exact` on the `User-Agent` header for the mobile-specific rule
- Order matters: place the header-matched rule before the fallback rule for `/auto`
- `parentRefs` in the HTTPRoute must reference the existing Gateway `r500-gateway`
- You may need to add `/etc/hosts` entry or use `curl --resolve` for `r500.gateway` to resolve to the node IP if DNS isn't configured

</details>
