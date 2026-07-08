#!/bin/bash
set -e

kubectl create namespace project-t230 --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /Volumes/Data 2>/dev/null || true

echo "Setup complete. Namespace project-t230 created."
