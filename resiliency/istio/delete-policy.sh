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
    echo "\"name\": \"$f\","
    echo "\"result\":"
    DOC=$(cat <<ENDOFDOC
{
    "name": "${f}",
    "user": "${KUBE_USER:-"minikube"}",
    "namespace": "${KUBE_NAMESPACE:-"default"}",
    "token": "${KUBE_TOKEN}",
    "type": "destinationpolicies",
    "locations": [
        {
            "name": "awsqa"
        }
    ]
}
ENDOFDOC
)
    echo $DOC | curl -k -H "Content-Type: application/json" -X DELETE -d @- $URL/api/v1/object
    echo "}"
done

echo
echo "]"
