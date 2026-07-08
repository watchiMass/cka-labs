# Question 7 | Node and Pod Resource Usage

Difficulty: Low

The metrics-server has been installed in the cluster. Write two bash scripts which use `kubectl`:

1. Script `/opt/course/7/node.sh` should show resource usage of nodes
2. Script `/opt/course/7/pod.sh` should show resource usage of Pods and their containers

<details><summary>Need a hint?</summary>

- `kubectl top node`
- `kubectl top pod --containers`
- Don't forget `chmod +x` and the `#!/bin/bash` shebang

</details>
