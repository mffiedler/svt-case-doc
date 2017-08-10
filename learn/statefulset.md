# StatefulSets

## Doc

* [statefulset@k8s](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
* [stateful-app@k8s](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/)
* [stateful-example@oc](https://github.com/openshift/origin/tree/master/examples/statefulsets)

## Practice stateful app in OC cluster
Run the following command if we use examples from the above k8s doc:

```sh
oadm policy add-scc-to-user anyuid -z default
```

## Use oc template
