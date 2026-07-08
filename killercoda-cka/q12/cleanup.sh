#!/bin/bash
kubectl delete namespace project-tiger --ignore-not-found=true --wait=false
echo "Cleanup complete"
