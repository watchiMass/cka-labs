#!/bin/bash
kubectl delete namespace project-swan --ignore-not-found=true --wait=false
rm -rf /opt/course/9
echo "Cleanup complete"
