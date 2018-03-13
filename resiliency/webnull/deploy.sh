#!/bin/bash

URL=${SkipperEndpoint:-'https://skipper.192.168.99.100.xip.io'}
sed -e "s/\${KUBE_TOKEN}/${KUBE_TOKEN}/" -e "s/\${KUBE_USER}/${KUBE_USER:-"minikube"}/" -e "s/\${KUBE_OWNER}/${KUBE_OWNER}/" -e "s/\${KUBE_NAMESPACE}/${KUBE_NAMESPACE:-"default"}/" ./deployment.json | curl -k -H "Content-Type: application/json" -X POST -d @- $URL/api/v1/deployment
