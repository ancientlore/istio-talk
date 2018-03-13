# webnull

This project deploys a QA instance of a [webnull] container for testing.

[webnull] is an open source project that accepts requests and throws them away. It's like a simpler version of [httpbin], and it has a graph to view requests.

![graph](webnull.png)

By using [webnull], you can test networks or connectivity.

> Note: These instructions assume a `bash` shell. On Windows, you can use `git-bash` which should be installed with [git](https://git-scm.com/).

## Endpoints

* `/status` shows the graph.
* `/delay/NNN` delays the response by `NNN` milliseconds and then returns `200 OK`.
* `/http/NNN` responds with an HTTP `NNN` code.
* Anything else response with `200 OK`.

## Deployment

To deploy the [webnull] container in `awsqa`, export the following environment variables and then run `./deploy.sh`.

* `KUBE_USER` - The Kubernetes user (defaults to `minikube`).
* `KUBE_TOKEN` - The Kubernetes token.
* `KUBE_NAMESPACE` - The Kubernetes namespace to deploy to (defaults to `default`).
* `KUBE_OWNER` - The owner.

> Note: Export a variable using, for example, `export KUBE_USER=my-kubernetes-user`, or assign it when calling the script like `KUBE_USER=my-kubernetes-user ./deploy.sh`.

### MiniKube Deployment

Make sure you have done `minikube addons enable ingress`.

    $ kubectl config use-context minikube
    $ export token=$(kubectl get secrets $(kubectl get secrets | grep default | grep service-account-token | awk '{print $1}') -o jsonpath='{.data.token}' | base64 -D)
    $ SkipperEndpoint=https://skipper.192.168.99.100.xip.io KUBE_NAMESPACE=default KUBE_TOKEN=$token KUBE_USER="" ./deploy.sh

Then check the UI at https://webnull-default.192.168.99.100.xip.io/.

[webnull]: https://github.com/ancientlore/webnull
[httpbin]: http://httpbin.org/
