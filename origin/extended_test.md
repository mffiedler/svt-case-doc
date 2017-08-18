# Extended-Test@Origin

## Doc

* [extended-test@oc-origin](https://github.com/openshift/origin/tree/master/test/extended)
* [e2e-test@k8s](https://github.com/kubernetes/community/blob/master/contributors/devel/e2e-tests.md)
* [ginkgo](ginkgo.md)
* report: a concept in
    [extended test](https://github.com/openshift/origin/blob/master/test/extended/util/test.go#L80)
    which is inherited from
    [k8s-e2c test](https://github.com/hongkailiu/kubernetes/blob/master/test/e2e/framework/util.go#L4491)
    which probably (need supporting proof) uses [ginkgo junit feature](https://onsi.github.io/ginkgo/#generating-junit-xml-output).
* label: a general rule about the character, eg, _slow_ and _flaky_,
    or the category, eg, _Conformance_, or the targeting component, eg,
    _router_, of the test. See [this test](https://github.com/openshift/origin/blob/master/test/extended/router/metrics.go#L25) for example.

## Build/Run test locally

```sh
# make build-extended-test
```

TODO: NOT working yet.
