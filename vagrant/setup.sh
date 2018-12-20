#!/bin/bash

wait_on_istio ()
{
	# wait for istio
	until [ `kubectl get pods -n istio-system | egrep -v '(Running|Completed)' | wc -l` -eq 1 ]
	do
		echo "Waiting for Istio"
		sleep 5
	done
}

wait_on_k8s ()
{
	# wait for kubernetes
	until [ `kubectl get pods -n kube-system | egrep 'Running' | wc -l` -ge 5 ]
	do
		echo "Waiting for Kubernetes"
		sleep 5
	done
}

sudo apt-get update
sudo apt-get upgrade -y

# Installing Git
sudo apt-get install -y git
sudo apt-get install -y jq
sudo apt-get install -y socat
sudo apt-get install -y gcc

# Installing Docker
echo "*** INSTALLING DOCKER ***"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu
sudo systemctl status docker
sudo usermod -aG docker ubuntu

# Installing kubectl
echo "*** INSTALLING KUBECTL ***"
sudo snap install kubectl --classic

# Install minikube
echo "*** INSTALLING MINIKUBE ***"
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.31.0/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# Get latest Istio
echo "*** GETTING ISTIO ***"
curl -L https://git.io/getLatestIstio | sh -
cd istio*
export PATH=$PWD/bin:$PATH
echo "export PATH=$PWD/bin:\$PATH" >> /home/vagrant/.profile
cd ..

# Start minikube
echo "*** STARTING MINIKUBE ***"
sudo minikube start --vm-driver=none --kubernetes-version=v1.10.3
# \
#    --extra-config=controller-manager.cluster-signing-cert-file="/var/lib/localkube/certs/ca.crt" \
#    --extra-config=controller-manager.cluster-signing-key-file="/var/lib/localkube/certs/ca.key"
sudo minikube addons enable ingress
sleep 10 # allow k8s components to start up
wait_on_k8s
kubectl get pods -n kube-system

echo "*** TEST KUBECTL ***"
kubectl config view
kubectl config use-context minikube

# Install Istio
echo "*** INSTALLING ISTIO ***"
cd istio*
kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
sleep 10 # allow CRDs to be committed in kube-apiserver
kubectl apply -f install/kubernetes/istio-demo-auth.yaml
#echo "*** INSTALLING ISTIO ADDONS ***"
#kubectl apply -f install/kubernetes/addons/
cd ..
wait_on_istio
kubectl get pods -n istio-system

# ingress
echo "*** INSTALLING ISTIO ADDONS GATEWAYS ***"
kubectl apply -f /vagrant/vagrant/istio/grafana-gateway.yaml
kubectl apply -f /vagrant/vagrant/istio/jaeger-gateway.yaml
kubectl apply -f /vagrant/vagrant/istio/servicegraph-gateway.yaml
kubectl apply -f /vagrant/vagrant/istio/zipkin-gateway.yaml
sleep 5

# k8s
echo "*** SETTING KUBERNETES VARIABLES ***"
export KUBE_NAMESPACE=default
echo "export KUBE_NAMESPACE=default" >> /home/vagrant/.profile

# pull images
echo "*** PULLING DOCKER IMAGES FOR LAB ***"
sudo docker pull ancientlore/topdog:v0.1.2
sudo docker pull ancientlore/hurl:v0.1.1
sudo docker pull ancientlore/webnull:v0.1.1

echo "*** INSTALLING DEMO CONTAINERS ***"
kubectl apply -f <(istioctl kube-inject -f /vagrant/resiliency/hurl/kube/deployment.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/resiliency/webnull/kube/deployment.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/trafficshifting/topdog/kube/deployment-be-v1.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/trafficshifting/topdog/kube/deployment-be-v2.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/trafficshifting/topdog/kube/deployment-be-v3.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/trafficshifting/topdog/kube/deployment-mt-v1.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/trafficshifting/topdog/kube/deployment-ui-v1.yaml)

echo "*** INSTALLING DEMO GATEWAYS ***"
kubectl apply -f /vagrant/vagrant/istio/demo-gateway.yaml

echo "*** ADDING ISTIO VIRTUAL SERVICES ***"
istioctl create -f /vagrant/trafficshifting/istio/services-all-v1.yaml -n default
istioctl create -f /vagrant/resiliency/istio/services.yaml -n default

# Adjust permissions due to having to run minikube as root
echo "*** UPDATING MINIKUBE CONFIG/PERMISSIONS ***"
sudo mv /root/.kube /home/vagrant/ # this will write over any previous configuration
sudo chown -R vagrant /home/vagrant/.kube
sudo chgrp -R vagrant /home/vagrant/.kube
#sudo mv /root/.minikube /home/vagrant/.minikube # this will write over any previous configuration
#sudo chown -R vagrant /home/vagrant/.minikube
#sudo chgrp -R vagrant /home/vagrant/.minikube 
sudo chown -R vagrant /root/.minikube
sudo chgrp -R vagrant /root/.minikube 
sudo chmod go+rx /root

# install Go
echo "*** INSTALLING GOLANG ***"
curl https://dl.google.com/go/go1.11.4.linux-amd64.tar.gz > go1.11.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.11.4.linux-amd64.tar.gz
export GOPATH=/home/vagrant
echo "export GOPATH=/home/vagrant" >> /home/vagrant/.profile
export PATH="$PATH:/usr/local/go/bin:/home/vagrant/bin"
echo "export PATH=\"$PATH:/usr/local/go/bin:/home/vagrant/bin\"" >> /home/vagrant/.profile
go env
echo "*** INSTALLING GO-based TOOLS ***"
go get golang.org/x/tools/cmd/present
go get golang.org/x/tools/cmd/stringer
git clone https://github.com/ancientlore/binder
git clone https://github.com/ancientlore/hurl
git clone https://github.com/ancientlore/webnull
git clone https://github.com/ancientlore/demon
git clone https://github.com/ancientlore/topdog
cd binder && go install && cd -
cd hurl && go install && cd -
cd webnull && go install && cd -
cd demon && go install && cd -
cd topdog && go install && cd -

sudo chown -R vagrant /home/vagrant/*
sudo chgrp -R vagrant /home/vagrant/* 

echo 'echo "NOTE:"' >> /home/vagrant/.profile
echo 'echo "Run /vagrant/vagrant-demo.sh to start the demo."' >> /home/vagrant/.profile
