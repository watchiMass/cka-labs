#!/bin/bash
kubectl delete namespace project-hamster --ignore-not-found=true --wait=false
echo "Cleanup complete"
