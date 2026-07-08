# Question 8 | Update Kubernetes Version and join cluster

Difficulty: Medium

Your coworker notified you that node `node01` is running an older Kubernetes version and is not even part of the cluster yet.

1. Update the node's Kubernetes to the exact version of the controlplane
2. Add the node to the cluster using kubeadm

<details><summary>Need a hint?</summary>

On `node01`:
```
apt-get update
apt-get install -y --allow-change-held-packages kubeadm=<version> kubelet=<version> kubectl=<version>
systemctl restart kubelet
```

On the controlplane, generate a join command:
```
kubeadm token create --print-join-command
```

Run the resulting `kubeadm join ...` command on `node01`.

</details>
