
echo "*** TEST KUBECTL ***"
kubectl config view
kubectl config use-context docker-for-desktop

# Wait for Istio
#echo "*** WAITING ON ISTIO ***"
#wait_on_istio

# ingress
echo "*** INSTALLING ISTIO ADDONS GATEWAYS ***"
kubectl apply -f ./docker/istio/grafana-gateway.yaml
kubectl apply -f ./docker/istio/jaeger-gateway.yaml
kubectl apply -f ./docker/istio/servicegraph-gateway.yaml
kubectl apply -f ./docker/istio/zipkin-gateway.yaml
sleep 5

# k8s
echo "*** SETTING KUBERNETES VARIABLES ***"
set KUBE_NAMESPACE=default

# pull images
echo "*** PULLING DOCKER IMAGES FOR LAB ***"
docker pull ancientlore/topdog:v0.1.2
docker pull ancientlore/hurl:v0.1.1
docker pull ancientlore/webnull:v0.1.1

echo "*** INSTALLING DEMO CONTAINERS ***"
istioctl kube-inject -f ./resiliency/hurl/kube/deployment.yaml > _hurl.yaml
kubectl apply -f _hurl.yaml
istioctl kube-inject -f ./resiliency/webnull/kube/deployment.yaml > _webnull.yaml
kubectl apply -f _webnull.yaml
istioctl kube-inject -f ./trafficshifting/topdog/kube/deployment-be-v1.yaml > _topdogbe1.yaml
kubectl apply -f _topdogbe1.yaml
istioctl kube-inject -f ./trafficshifting/topdog/kube/deployment-be-v2.yaml > _topdogbe2.yaml
kubectl apply -f _topdogbe2.yaml
istioctl kube-inject -f ./trafficshifting/topdog/kube/deployment-be-v3.yaml > _topdogbe3.yaml
kubectl apply -f _topdogbe3.yaml
istioctl kube-inject -f ./trafficshifting/topdog/kube/deployment-mt-v1.yaml > _topdogmt1.yaml
kubectl apply -f _topdogmt1.yaml
istioctl kube-inject -f ./trafficshifting/topdog/kube/deployment-ui-v1.yaml > _topdogui1.yaml
kubectl apply -f _topdogui1.yaml
rm _*.yaml

echo "*** INSTALLING DEMO GATEWAYS ***"
kubectl apply -f ./docker/istio/demo-gateway.yaml

echo "*** ADDING ISTIO VIRTUAL SERVICES ***"
istioctl create -f ./trafficshifting/istio/services-all-v1.yaml -n default
istioctl create -f ./resiliency/istio/services.yaml -n default

echo 'echo "Run ./demo.sh to start the demo."'
