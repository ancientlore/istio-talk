#!/bin/bash

w="https://webnull-default.192.168.99.100.xip.io/status/"
h="https://hurl-default.192.168.99.100.xip.io/"
p=`kubectl get pod -l service=hurl -o name | sed 's/^pods\///'`

WEBNULL=$w HURL=$h POD=$p demon
