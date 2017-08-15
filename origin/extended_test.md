# Extended-Test@Origin

## Doc

* [ginkgo](ginkgo.md)
* report: a concept in
    [extended test](https://github.com/openshift/origin/blob/master/test/extended/util/test.go#L80)
    which is inherited from
    [k8s-e2c test](https://github.com/hongkailiu/kubernetes/blob/master/test/e2e/framework/util.go#L4491).
* label: a general rule about the character, eg, _slow_ and _flaky_,
    or the category, eg, _Conformance_, or the targeting component, eg,
    _router_, of the test. See [this test](https://github.com/openshift/origin/blob/master/test/extended/router/metrics.go#L25) for example.

## TODO