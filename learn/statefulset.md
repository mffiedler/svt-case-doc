# StatefulSets

## Doc

* [statefulset@k8s](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
* [stateful-app@k8s](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/)
* [stateful-example@oc](https://github.com/openshift/origin/tree/master/examples/statefulsets)

## Usage

* Fixed network identity
* Fixed storage
* Order start/termination order

## Practice stateful app in OC cluster
Run the following command if we use examples () from the above k8s doc:

```sh
oadm policy add-scc-to-user anyuid -z default
```

Note that the following command did not work yet in the test:

```sh
# kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate"}}}'
statefulset "web" not patched
```

Test is done till <code>Staging an Update</code> section. Leave the rest as TODO for the moment.

## Use oc template
Here we use probably a more realistic example: 2 replicas in <code>statefulset</code> share volumes.
