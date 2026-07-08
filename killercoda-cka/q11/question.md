# Question 11 | DaemonSet on all Nodes

Difficulty: Medium

Use Namespace `project-tiger` for the following. Create a DaemonSet named `ds-important` with image `httpd:2-alpine` and labels `id=ds-important` and `uuid=18426a0b-5f59-4e10-923f-c0e078e82462`. The Pods it creates should request 10 millicore cpu and 10 mebibyte memory. The Pods of that DaemonSet should run on all nodes, also controlplanes.

<details><summary>Need a hint?</summary>

Controlplane nodes usually have a `NoSchedule` taint (e.g. `node-role.kubernetes.io/control-plane`). Add a toleration for it in the Pod template so the DaemonSet also schedules there.

```
kubectl -n project-tiger get nodes -o jsonpath='{.items[*].spec.taints}'
```

</details>
