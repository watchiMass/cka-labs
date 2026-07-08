#!/bin/bash
kubectl delete namespace project-h800 --ignore-not-found=true --wait=false
echo "Cleanup complete"
