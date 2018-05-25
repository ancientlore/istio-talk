#!/bin/bash

# Use this in the Vagrant box to run all the demos
# Port 8080 - The presentation
# Port 8081 - Traffic Shifting Demo
# Port 8081 - Resiliency Demo (after pressing return)
pushd /vagrant

addr=192.168.99.101

ctx=`kubectl config current-context`
echo kube context is $ctx
ns=`kubectl config view -o jsonpath="{.contexts[?(@.name == \"$ctx\")].context.namespace}"`
ns=${ns:-default}
echo KUBE_NAMESPACE is $ns

t="http://topdog.$addr.xip.io/"

w="http://webnull.$addr.xip.io/status/"

h="http://hurl.$addr.xip.io/"
hp=`kubectl get pod -l app=hurl -o name | sed 's/^pod\///'`
echo HURL pod is $hp

# run present
present -notes -http 192.168.99.101:8080 -play=false &
pid=$!

# traffic shifting demo
echo "*** TRAFFIC SHIFTING DEMO ***"
cd trafficshifting
KUBE_NAMESPACE=$ns TOPDOG=$t demon -addr :8081
cd ..

# resiliency shifting demo
echo "*** RESILIENCY DEMO ***"
cd resiliency
KUBE_NAMESPACE=$ns WEBNULL=$w HURL=$h POD=$hp demon -addr :8081
cd ..

# stop present
kill -9 $pid

popd
