#!/bin/bash
kubectl delete namespace project-t230 --ignore-not-found=true --wait=false
kubectl delete pv safari-pv --ignore-not-found=true
echo "Cleanup complete"
