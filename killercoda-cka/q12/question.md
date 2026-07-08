# Question 12 | Deployment on all Nodes

Difficulty: Medium

Implement the following in Namespace `project-tiger`:

- Create a Deployment named `deploy-important` with 3 replicas
- The Deployment and its Pods should have label `id=very-important`
- First container named `container1` with image `nginx:1-alpine`
- Second container named `container2` with image `registry.k8s.io/pause:3.10`
- There should only ever be **one** Pod of that Deployment running on **one** worker node, use `topologyKey: kubernetes.io/hostname` for this

<details><summary>Need a hint?</summary>

Use `podAntiAffinity` with `requiredDuringSchedulingIgnoredDuringExecution` matching label `id=very-important` and `topologyKey: kubernetes.io/hostname`.

</details>
