# Fading docker

## Original picture

![](../images/atomic.1.png)

So many features reply on docker and soon enough this became restrictions. As a result, this original picture looks like:

![](../images/atomic.2.png)

People want to see alternatives to docker while docker is still dominating containers world.

## [CRI-O](cri_o.md)

A docker implementation for k8s. Put it in another way, we can run k8s with cri-o without docker.

![](http://cri-o.io/assets/images/architecture.png)

Its components:

* OCI compatible runtime, eg, runc
* container storage, eg, overlay2, devicemapper
* container image, a library supporting _skopeo_
* networking (CNI), eg, openshift-SND (using openvswitch), flannel
* container monitoring (conmon)
* security is provided by several core Linux capabilities
