# Question 16 | Update CoreDNS Configuration

Difficulty: Medium

The CoreDNS configuration in the cluster needs to be updated:

1. Make a backup of the existing configuration Yaml and store it at `/opt/course/16/coredns_backup.yaml`. You should be able to fast recover from the backup
2. Update the CoreDNS configuration in the cluster so that DNS resolution for `SERVICE.NAMESPACE.custom-domain` will work exactly like and in addition to `SERVICE.NAMESPACE.cluster.local`

Test your configuration for example from a Pod with `busybox:1` image. These commands should result in an IP address:

```
nslookup kubernetes.default.svc.cluster.local
nslookup kubernetes.default.svc.custom-domain
```

<details><summary>Need a hint?</summary>

- `kubectl -n kube-system get configmap coredns -o yaml > /opt/course/16/coredns_backup.yaml`
- Edit the `Corefile` inside the `coredns` ConfigMap: add `custom-domain` as an extra zone alongside `cluster.local` in the `kubernetes` plugin block, e.g. `kubernetes cluster.local custom-domain in-addr.arpa ip6.arpa {`
- `kubectl -n kube-system rollout restart deployment coredns` after editing to reload config

</details>
