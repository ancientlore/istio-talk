# istio-talk

This repository contains code for my talk on [Istio].

> Stay tuned! I'm doing some work to run the demos more easily. I just moved it from our corporate environment.

## Resiliency Demo

See the [walk-through](resiliency/README.md).

![Resiliency Demo](resiliency_demo.png)

## Traffic Shifting Demo

See the [walk-through](trafficshifting/README.md).

![Traffic Shifting Demo](trafficshifting_demo.png)

## Notes

These demos use other utilities I've created:

* [topdog], a demo application written in Go. Also see the [topdog Docker image].
* [webnull], a service that tosses away requests and graphs throughput. Also see the [webnull Docker image].
* [hurl], a cURL-like application designed to send many parallel HTTP requests to generate load. Also see the [hURL Docker image].
* [demon], a utility for showing the demos on one unified web page.

[Istio]: https://istio.io/
[topdog]: https://github.com/ancientlore/topdog
[hURL]: https://github.com/ancientlore/hurl
[webnull]: https://github.com/ancientlore/webnull
[topdog Docker image]: https://hub.docker.com/r/ancientlore/topdog/
[webnull Docker image]: https://hub.docker.com/r/ancientlore/webnull/
[hURL Docker image]: https://hub.docker.com/r/ancientlore/hurl/
[demon]: https://github.com/ancientlore/demon
