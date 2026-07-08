#!/bin/bash
set -e

kubectl create namespace project-tiger --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete. Namespace project-tiger created."
echo "Note: this exercise requires at least 3 worker nodes to fully validate placement."
kubectl get nodes
