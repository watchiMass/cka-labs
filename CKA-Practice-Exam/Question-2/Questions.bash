# Question 2 (Hard) — Cluster Architecture: Join a Second Control-Plane Node
# Domain: Cluster Architecture, Installation & Configuration (25%)

# Scenario
# Your cluster currently has a single control-plane node ("cp-node-1") and
# is at risk of becoming a single point of failure. You must extend it into
# a highly-available control plane by joining "cp-node-2" as an additional
# control-plane node using kubeadm.

# Tasks
# 1. On cp-node-1, ensure certificates are uploaded and a join command with
#    a valid token is available (already prepared by LabSetUp.bash; if it
#    has expired, regenerate it).
# 2. SSH into cp-node-2.
# 3. Run the kubeadm join command on cp-node-2 with the --control-plane and
#    --certificate-key flags so it joins as a control-plane node (NOT a
#    worker).
# 4. After the join completes, copy the admin kubeconfig to cp-node-2 so
#    kubectl works there too:
#      mkdir -p $HOME/.kube
#      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#      sudo chown $(id -u):$(id -g) $HOME/.kube/config
# 5. From either control-plane node, confirm both nodes show
#    ROLES=control-plane and STATUS=Ready.
# 6. Confirm there are now 2 members in the etcd cluster
#    (etcdctl member list).

# Constraints
# - Do not join cp-node-2 as a worker node by omitting --control-plane.
# - Do not disable the firewall; instead open the specific ports required
#   for etcd peer communication (2379-2380) and the kubelet API (10250)
#   if the join fails due to connectivity.

# Documentation Reference
# Setup -> Production Environment -> kubeadm -> Creating Highly Available Clusters with kubeadm
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
