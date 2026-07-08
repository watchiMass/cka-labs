#!/bin/bash
kubectl delete namespace project-c13 --ignore-not-found=true --wait=false
rm -rf /opt/course/4
echo "Cleanup complete"
