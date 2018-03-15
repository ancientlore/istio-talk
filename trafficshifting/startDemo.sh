#!/bin/bash

t="http://localhost:5000"

# start port-forward
hp=`kubectl get pod -l service=topdogui -o name | sed 's/^pods\///'`
kubectl port-forward $hp 5000 &
hpid=$!

TOPDOG=$t demon

kill -15 $hpid
