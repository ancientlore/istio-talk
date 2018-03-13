#!/bin/bash

# Note: this script uses Skipper's object API. Therefore, a "type" field is needed in the JSON.

echo "["

let COUNTER=0

URL=${SkipperEndpoint:-'https://skipper.192.168.99.100.xip.io'}

for f in "$@"
do
    if [ $COUNTER -gt 0 ]; then
        echo ','
    fi
    let COUNTER=COUNTER+1
    echo "{"
    echo "\"file\": \"$f\","
    echo "\"result\":"
    sed -e "s/\${KUBE_TOKEN}/${KUBE_TOKEN}/" -e "s/\${KUBE_USER}/${KUBE_USER:-"minikube"}/" -e "s/\${KUBE_OWNER}/${KUBE_OWNER}/" -e "s/\${KUBE_NAMESPACE}/${KUBE_NAMESPACE:-"default"}/" $f | curl -k -H "Content-Type: application/json" -X POST -d @- $URL/api/v1/object
    echo "}"
done

echo
echo "]"
