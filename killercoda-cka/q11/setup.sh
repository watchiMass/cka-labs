#!/bin/bash
set -e

kubectl create namespace project-tiger --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete. Namespace project-tiger created."
kubectl get nodes
