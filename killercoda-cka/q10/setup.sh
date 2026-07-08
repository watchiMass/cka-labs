#!/bin/bash
set -e

kubectl create namespace project-hamster --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete. Namespace project-hamster created."
