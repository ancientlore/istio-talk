#!/bin/bash

wait_on_istio ()
{
	# wait for istio
	until kubectl get pods -n istio-system | grep '^istio-ca.*Running'
	do
		echo "Waiting on istio-ca"
		sleep 5
	done
	until kubectl get pods -n istio-system | grep '^istio-mixer.*Running'
	do
		echo "Waiting on istio-mixer"
		sleep 5
	done
	until kubectl get pods -n istio-system | grep '^istio-pilot.*Running'
	do
		echo "Waiting on istio-pilot"
		sleep 5
	done
	until kubectl get pods -n istio-system | grep 'istio-ingress.*Running'
	do
		echo "Waiting on istio-ingress"
		sleep 5
	done
}

wait_on_k8s ()
{
	# wait for kubernetes
	until [ `kubectl get pods -n kube-system | grep Running | wc -l` -eq 6 ]
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

# Installing Docker
echo "*** INSTALLING DOCKER ***"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo systemctl status docker
sudo usermod -aG docker ubuntu

# Installing kubectl
echo "*** INSTALLING KUBECTL ***"
sudo snap install kubectl --classic

# Install minikube
echo "*** INSTALLING MINIKUBE ***"
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.25.0/minikube-linux-amd64
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
sudo minikube start --vm-driver=none \
	--extra-config=controller-manager.ClusterSigningCertFile="/var/lib/localkube/certs/ca.crt" \
	--extra-config=controller-manager.ClusterSigningKeyFile="/var/lib/localkube/certs/ca.key" \
	--extra-config=apiserver.Admission.PluginNames=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota \
	--kubernetes-version=v1.9.0
sudo minikube addons enable ingress
sleep 5 # allow k8s components to start up
wait_on_k8s

echo "*** TEST KUBECTL ***"
kubectl config view
kubectl config use-context minikube

# Install Istio
echo "*** INSTALLING ISTIO ***"
cd istio*
kubectl apply -f install/kubernetes/istio-auth.yaml
echo "*** INSTALLING ISTIO ADDONS ***"
kubectl apply -f install/kubernetes/addons/
cd ..
wait_on_istio

# ingress
echo "*** INSTALLING ISTIO ADDONS INGRESS***"
kubectl apply -f /vagrant/vagrant/istio/
sleep 5

# k8s
echo "*** SETTING KUBERNETES VARIABLES ***"
export KUBE_NAMESPACE=default
echo "export KUBE_NAMESPACE=default" >> /home/vagrant/.profile

# pull images
echo "*** PULLING DOCKER IMAGES FOR LAB ***"
sudo docker pull ancientlore/topdog:0.1.1
sudo docker pull ancientlore/hurl:0.1
sudo docker pull ancientlore/webnull:0.1

echo "*** INSTALLING DEMO CONTAINERS ***"
kubectl apply -f <(istioctl kube-inject -f /vagrant/resiliency/hurl/kube/deployment.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/resiliency/webnull/kube/deployment.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/trafficshifting/topdog/kube/deployment-be-v1.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/trafficshifting/topdog/kube/deployment-be-v2.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/trafficshifting/topdog/kube/deployment-be-v3.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/trafficshifting/topdog/kube/deployment-mt-v1.yaml)
kubectl apply -f <(istioctl kube-inject -f /vagrant/trafficshifting/topdog/kube/deployment-ui-v1.yaml)

echo "*** ADDING ISTIO RULES ***"
istioctl create -f /vagrant/trafficshifting/istio/route-rule-all-v1.yaml -n default
istioctl create -f /vagrant/resiliency/istio/route-rule.yaml -n default
istioctl create -f /vagrant/resiliency/istio/circuit-breaker.yaml -n default

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
curl https://dl.google.com/go/go1.10.2.linux-amd64.tar.gz > go1.10.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.10.2.linux-amd64.tar.gz
export GOPATH=/home/vagrant
echo "export GOPATH=/home/vagrant" >> /home/vagrant/.profile
export PATH="$PATH:/usr/local/go/bin:/home/vagrant/bin"
echo "export PATH=\"$PATH:/usr/local/go/bin:/home/vagrant/bin\"" >> /home/vagrant/.profile
go env
echo "*** INSTALLING GO-based TOOLS ***"
go get golang.org/x/tools/cmd/present
go get golang.org/x/tools/cmd/stringer
go get github.com/ancientlore/binder
go get github.com/ancientlore/hurl
go get github.com/ancientlore/webnull
go get github.com/ancientlore/demon
go get github.com/ancientlore/topdog

