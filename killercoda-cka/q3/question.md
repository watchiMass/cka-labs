# Question 3 | Scale down StatefulSet

Difficulty: Low

There are two Pods named `o3db-*` in Namespace `project-h800`. The Project H800 management asked you to scale these down to one replica to save resources.

<details><summary>Need a hint?</summary>

- `kubectl -n project-h800 get statefulset`
- `kubectl -n project-h800 scale statefulset o3db --replicas=1`

</details>
