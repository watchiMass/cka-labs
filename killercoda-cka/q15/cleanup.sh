#!/bin/bash
kubectl delete namespace project-snake --ignore-not-found=true --wait=false
echo "Cleanup complete"
