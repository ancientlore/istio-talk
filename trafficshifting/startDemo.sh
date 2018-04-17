#!/bin/bash

ctx=`kubectl config current-context`
echo kube context is $ctx
ns=`kubectl config view -o jsonpath="{.contexts[?(@.name == \"$ctx\")].context.namespace}"`
ns=${ns:-default}
echo KUBE_NAMESPACE is $ns

t="http://localhost:8081"

# start port-forward
hp=`kubectl get pod -l app=topdogui -o name | sed 's/^pods\///'`
kubectl port-forward $hp 8081:5000 &
hpid=$!
echo TOPDOG pod is $hp

KUBE_NAMESPACE=$ns TOPDOG=$t demon

kill -15 $hpid
