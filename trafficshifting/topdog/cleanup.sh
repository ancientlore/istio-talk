#!/bin/bash

kubectl delete deployment topdogui-v1
kubectl delete deployment topdogmt-v1
kubectl delete deployment topdogbe-v1
kubectl delete deployment topdogbe-v2
kubectl delete deployment topdogbe-v3
kubectl delete all -l service=topdogui
kubectl delete all -l service=topdogmt
kubectl delete all -l service=topdogbe
kubectl delete service topdogui
kubectl delete service topdogmt
kubectl delete service topdogbe
kubectl delete ingress topdogui
