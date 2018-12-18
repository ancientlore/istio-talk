#!/bin/bash

# Use this in the Vagrant box to run all the demos
# Port 8080 - The presentation
# Port 8081 - Traffic Shifting Demo
# Port 8081 - Resiliency Demo (after pressing return)
pushd /vagrant

addr=192.168.99.101

./demo.sh $addr
