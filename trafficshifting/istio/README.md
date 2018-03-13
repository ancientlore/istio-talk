# istio files

There are two sets of files - the `yaml` files are for use with `istioctl`, and the `json` files are for use with `deploy-object.sh` (which uses Skipper).

## Using `istioctl`

The `istioctl` command is much like `kubectl`, but it will validate the `yaml` file.

    istioctl create -f <filename>.yaml --namespace=default

You can also use `kubectl`:

    kubectl create -f <filename>.yaml --namespace=default
    
## Using Skipper

The `deploy-object.sh` script will post to Skipper.

    ./deploy-object.sh <filename>.json

You can optionally override:

* `KUBE_USER` - The Kubernetes user (defaults to `minikube`).
* `KUBE_TOKEN` - The Kubernetes token.
* `KUBE_NAMESPACE` - The Kubernetes namespace to deploy to (defaults to `default`).
* `KUBE_OWNER` - The owner.
