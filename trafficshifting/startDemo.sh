#!/bin/bash

t="http://localhost:8081"

# start port-forward
hp=`kubectl get pod -l service=topdogui -o name | sed 's/^pods\///'`
kubectl port-forward $hp 8081:5000 &
hpid=$!

TOPDOG=$t demon

kill -15 $hpid
