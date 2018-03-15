#!/bin/bash

w="http://localhost:8081/status/"
h="http://localhost:8082/"

# start port-forward
wp=`kubectl get pod -l service=webnull -o name | sed 's/^pods\///'`
kubectl port-forward $wp 8081:8080 &
wpid=$!

# start port-forward
hp=`kubectl get pod -l service=hurl -o name | sed 's/^pods\///'`
kubectl port-forward $hp 8082:8080 &
hpid=$!

WEBNULL=$w HURL=$h POD=$hp demon

kill -15 $hpid
kill -15 $wpid
