#!/bin/bash
kubectl delete namespace api-gateway-staging --ignore-not-found=true --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found=true --wait=false
rm -rf /opt/course/5
echo "Cleanup complete"
