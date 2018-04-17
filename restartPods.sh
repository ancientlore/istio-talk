#!/bin/bash

kubectl delete pod -n istio-system --all
sleep 10
kubectl delete pod -l app=webnull
kubectl delete pod -l app=hurl
kubectl delete pod -l app=topdogbe
kubectl delete pod -l app=topdogmt
kubectl delete pod -l app=topdogui

