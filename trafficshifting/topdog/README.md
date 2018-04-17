# topdog

This project deploys a QA instance of the [topdog] application for testing.

[topdog] is a simple three-tier application.

![topdog tiers](topdog.png)

* The _backend_ returns random, weighted data about who the "top dog" architect is at any given moment.
* The _midtier_ queries the backend for the "top dog".
* The _UI_ queries the midtier and displays realtime results.

The deployment includes three versions of the backend. Ordinarily, you would not deploy all three at once, but for this demo that works well. The midtier is essentially a pass-through, but in practice could have other business logic.

> Note: Each tier uses the same Docker image. This is just for simplicity.

> Note: These instructions assume a `bash` shell. On Windows, you can use `git-bash` which should be installed with [git](https://git-scm.com/).

## UI Endpoints

* `/` shows the UI.
* `/query` gets the "top dog".
* `/static/*` returns static content.

## Midtier Endpoints

* `/midtier` returns the "top dog" from the midtier, which has to query the backend to get it.

## Backend Endpoints

* `/backend` computes the "top dog" using a random, weighted system.

## Deployment

To deploy the [topdog] container without [Istio] *or* if you have Istio automatic sidecar injection enabled, run:

    $ kubectl apply -f ./kube/

To deploy the [topdog] containers with [Istio] and automatic sidecar injection is not enabled, run:

    $ kubectl apply -f <(istioctl kube-inject -f ./kube/deployment-be-v1.yaml)
    $ kubectl apply -f <(istioctl kube-inject -f ./kube/deployment-be-v2.yaml)
    $ kubectl apply -f <(istioctl kube-inject -f ./kube/deployment-be-v3.yaml)
    $ kubectl apply -f <(istioctl kube-inject -f ./kube/deployment-mt-v1.yaml)
    $ kubectl apply -f <(istioctl kube-inject -f ./kube/deployment-ui-v1.yaml)

You can check the UI by using a port-forward and then browsing to http://localhost:5000/.

    $ hp=`kubectl get pod -l app=topdogui -o name | sed 's/^pods\///'`
    $ kubectl port-forward $hp 5000

## Brought to you by:

![dogs](dogs.png)

[Istio]: https://istio.io/
[topdog]: https://github.com/ancientlore/topdog
