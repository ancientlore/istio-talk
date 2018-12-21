
kubectl delete gateway -n istio-system grafana-gateway
kubectl delete gateway -n istio-system jaeger-gateway
kubectl delete gateway -n istio-system servicegraph-gateway
kubectl delete gateway -n istio-system zipkin-gateway

kubectl delete destinationrule -n istio-system grafana
kubectl delete destinationrule -n istio-system jaeger
kubectl delete destinationrule -n istio-system servicegraph
kubectl delete destinationrule -n istio-system zipkin

kubectl delete virtualservice -n istio-system grafana
kubectl delete virtualservice -n istio-system jaeger
kubectl delete virtualservice -n istio-system servicegraph
kubectl delete virtualservice -n istio-system zipkin

kubectl delete gateway -n default topdog-gateway
kubectl delete gateway -n default webnull-gateway
kubectl delete gateway -n default hurl-gateway

kubectl delete destinationrule -n default topdogbe
kubectl delete destinationrule -n default topdogmt
kubectl delete destinationrule -n default topdogui
kubectl delete destinationrule -n default webnull
kubectl delete destinationrule -n default hurl

kubectl delete virtualservice -n default topdogbe
kubectl delete virtualservice -n default topdogmt
kubectl delete virtualservice -n default topdogui
kubectl delete virtualservice -n default webnull
kubectl delete virtualservice -n default hurl

kubectl delete deployment -n default hurl
kubectl delete deployment -n default webnull
kubectl delete deployment -n default topdogbe-v1
kubectl delete deployment -n default topdogbe-v2
kubectl delete deployment -n default topdogbe-v3
kubectl delete deployment -n default topdogmt-v1
kubectl delete deployment -n default topdogui-v1

kubectl delete service -n default hurl
kubectl delete service -n default webnull
kubectl delete service -n default topdogbe
kubectl delete service -n default topdogmt
kubectl delete service -n default topdogui
