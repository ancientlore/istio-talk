# Resiliency Demo using Istio

This demo shows a mock service, [webnull], that just throws away requests. Another mock service, [hurl], is really a tool to send parallel HTTP requests to [webnull] to simulate load. We will use [Istio] to test circuit breakers, inject faults, and inject delays. These tools can be used to test how upsteam services respond to problems.

![service diagram](resiliency.png)

What is great about [Istio] is that these functions are part of the _infrastructure_ - no special coding is needed in [hurl] or [webnull] to take advantage of these features. [Istio] also has a great [dashboard](https://grafana.192.168.99.100.xip.io/dashboard/db/istio-dashboard), a [service graph](https://servicegraph.192.168.99.100.xip.io/dotviz?filter_empty=true&time_horizon=10m), and a [trace analyzer](https://zipkin.192.168.99.100.xip.io/zipkin/).

> Note: These instructions assume a `bash` shell. On Windows, you can use `git-bash` which should be installed with [git](https://git-scm.com/).

## Setup

Export the following variables which are used by the commands in this demo:

* `KUBE_USER` - The Kubernetes user (like `minikube`, but use yours).
* `KUBE_TOKEN` - The Kubernetes token.
* `KUBE_NAMESPACE` - The Kubernetes namespace to deploy to (like `default`, but use yours).
* `KUBE_OWNER` - The owner.

> Note: Export a variable using, for example, `export KUBE_USER=my-kubernetes-user`, or assign it when calling the script like `KUBE_USER=my-kubernetes-user ./deploy.sh`.

Deploy [webnull] according to its [instructions](webnull/README.md):

    $ cd webnull
    $ ./deploy.sh

Then deploy [hurl] according to its [instructions](hurl/README.md):

    $ cd hurl
    $ ./deploy.sh

Make sure the containers are running:

    $ kubectl get pods
    NAME                              READY     STATUS    RESTARTS   AGE
    hurl-4211406881-d8rz5             2/2       Running   0          1m
    webnull-3334364612-nlwsr          2/2       Running   0          1m

Set up the route rules for each service, and the circuit breaker destination policy:

    $ cd istio
    $ istioctl create -f route-rule.yaml --namespace=$KUBE_NAMESPACE
    $ istioctl create -f circuit-breaker.yaml --namespace=$KUBE_NAMESPACE

> Note that you can generally use `kubectl` instead of `istioctl`, but `istioctl` provides additional client-side validation.

Or, if you prefer the Skipper version (see the [instructions](istio/README.md)):

    $ cd istio
    $ ./deploy-object.sh route-rule-webnull.json route-rule-hurl.json
    $ ./deploy-object.sh circuit-breaker.json

You can check the route rules using `istioctl get routerules` or `kubectl get routerules`. You can also fetch an individual rule using:

    $ istioctl get routerule webnull-default --namespace=$KUBE_NAMESPACE -o yaml
    $ istioctl get routerule hurl-default --namespace=$KUBE_NAMESPACE -o yaml

Similarly, you can get destination policies using `istioctl get destinationpolicies` or fetch an individual one:

    $ istioctl get destinationpolicy webnull-circuit-breaker --namespace=$KUBE_NAMESPACE -o yaml

You're now ready to proceed with the demo.

## Starting the Demo

Start [hurl] with a basic request set.

    $ kubectl exec -it $(kubectl get pod -l service=hurl -o name | sed 's/^pods\///') /bin/sh
    # hurl -conns 10 -loop 2000000 http://webnull:8080/xml

> Stay logged into the [hurl] container so that you can exercise commands later.

Look at the [webnull] dashboard - it shows incoming request volume and bytes received if it was a POST or PUT. This small utility can be used to check what sort of throughput you could achieve, assuming your service had no actual work to do.

Now look at the [hurl] dashboard. [hurl] was created to work similarly to [curl], except that it sends requests in parallel to load up some other service. The dashboard shows graphs of response codes, bytes recieved, and request round-trip time. We will be using [hurl] to send load to [webnull], and then checking what happens when we exercise [Istio] features.

> Note: Run the [Istio] commands from the `istio` folder.

We have already set up a [default routerule](istio/route-rule.yaml) in [Istio]:

    $ istioctl get routerule webnull-default --namespace=$KUBE_NAMESPACE -o yaml

Also, we have a [circuit breaker](istio/circuit-breaker.yaml) set up:

    $ istioctl get destinationpolicy webnull-circuit-breaker --namespace=$KUBE_NAMESPACE -o yaml

At this point, the service is "operating normally".

For the rest of the demo, you can use `istioctl` commands or scripts that post to [Skipper].

> See region A on the diagram below

## Circuit Breaker

To trigger the circuit breaker, restart [hurl] with more connections:

    # hurl -conns 100 -loop 2000000 http://webnull:8080/xml 

Note the large number of HTTP 503 responses from the circuit breaker.

> See region B on the diagram below

Now restart [hurl] with a normal number of connections.

    # hurl -conns 10 -loop 2000000 http://webnull:8080/xml

Things return to normal, although [Istio] may still have the circuit breaker triggered.

> See region C on the diagram below

## Fault Injection

Next, we will inject [faults](istio/inject-abort.yaml) into the system.

    $ istioctl create -f inject-abort.yaml --namespace=$KUBE_NAMESPACE

Skipper version:

    $ ./deploy-object.sh inject-abort.json

Note the HTTP 400 responses from the fault. This can be used to test how upstream services respond to failures.

> See region D on the diagram below

Now remove the fault:

    $ istioctl delete routerule webnull-test-abort --namespace=$KUBE_NAMESPACE

Skipper version:

    $ ./delete-rule.sh webnull-test-abort

Note how the service returns to normal.

> See region E on the diagram below

## Delay Injection

We will now inject a [small delay](istio/inject-delay.yaml) into some percentage of the requests.

    $ istioctl create -f inject-delay.yaml --namespace=$KUBE_NAMESPACE

Skipper version:

    $ ./deploy-object.sh inject-delay.json

Note that even with this small delay, the service doesn't process as many transactions.

> See region F on the diagram below

Remove the small delay:

    $ istioctl delete routerule webnull-test-delay --namespace=$KUBE_NAMESPACE

Skipper version:

    $ ./delete-rule.sh webnull-test-delay

Note the service return to normal.

> See region G on the diagram below

## Big Delay Injection

Now let's inject a [larger delay](istio/inject-big-delay.yaml) on more requests, simulating a potential database performance issue.

    $ istioctl create -f inject-big-delay.yaml --namespace=$KUBE_NAMESPACE

Skipper version:

    $ ./deploy-object.sh inject-big-delay.json

Note how the service practically falls over.

> See region H on the diagram below

But to be realistic, let's add far more connections to similate requests from clients piling up.

    # hurl -conns 100 -loop 2000000 http://webnull:8080/xml 

Note that the service improves, but is still hurting. In some cases it might also trigger the circuit breaker.

> See region I on the diagram below

"Fix the database" and remove the delay.

    $ istioctl delete routerule webnull-test-bigdelay --namespace=$KUBE_NAMESPACE

Skipper version:

    $ ./delete-rule.sh webnull-test-bigdelay

Now the circuit breaker is triggering - why? The reason is that we still have many requests going.

> See region J on the diagram below

 In reality the request rate would come back under control once the service speeds up, so let's adjust [hurl] for that.

    # hurl -conns 10 -loop 2000000 http://webnull:8080/xml

The circuit breaker has a memory and still may trigger, but things are getting back to normal.

> See region K on the diagram below

## Request Timeouts

To test request timeouts, first try a long-running page without a timeout in place:

    # hurl http://webnull:8080/delay/5000

Next, set up the [request timeout](istio/request-timeout.yaml) route rule.

    $ istioctl create -f request-timeout.yaml --namespace=$KUBE_NAMESPACE

Skipper version:

    $ ./deploy-object.sh request-timeout.json

Wait a moment for the Istio proxy to update, then try the request again:

    # hurl http://webnull:8080/delay/5000
    2018/01/25 21:47:47 Failed to post to http://webnull:8080/delay/5000, status 504 Gateway Timeout

Clean up the rule:

    $ istioctl delete routerule webnull-request-timeout --namespace=$KUBE_NAMESPACE

Skipper version:

    $ ./delete-rule.sh webnull-request-timeout

## Diagram

![diagram](istio.png)

## Closing Thoughts

* [Istio] takes several problems that used to be (inconsistently implemented) coding exercises and makes them a consistent part of the infrastructure.
* Testing upstream service behavior is easily accomplished by injecting faults and delays.
* Circuit breakers can use used to protect upstream (and downtream) services from overload.
* HTTP timeouts are easily controlled, even when the service implementations don't set them explicitly.
* [Istio] can be extended to services outside of Kubernetes.
* [Istio] includes much more, including mutual TLS between services, throttling, and monitoring.

[webnull]: https://webnull-default.192.168.99.100.xip.io/status/
[hurl]: https://hurl-default.192.168.99.100.xip.io/
[Istio]: https://istio.io/
[curl]: https://curl.haxx.se/
[Skipper]: https://github.com/concur/skipper