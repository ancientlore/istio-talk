#!/bin/bash

ctx=`kubectl config current-context`
echo kube context is $ctx
ns=`kubectl config view -o jsonpath="{.contexts[?(@.name == \"$ctx\")].context.namespace}"`
ns=${ns:-default}
echo KUBE_NAMESPACE is $ns

w="http://localhost:8081/status/"
h="http://localhost:8082/"

# start port-forward
wp=`kubectl get pod -l service=webnull -o name | sed 's/^pods\///'`
kubectl port-forward $wp 8081:8080 &
wpid=$!
echo WEBNULL pod is $wp

# start port-forward
hp=`kubectl get pod -l service=hurl -o name | sed 's/^pods\///'`
kubectl port-forward $hp 8082:8080 &
hpid=$!
echo HURL pod is $hp

KUBE_NAMESPACE=$ns WEBNULL=$w HURL=$h POD=$hp demon

kill -15 $hpid
kill -15 $wpid
