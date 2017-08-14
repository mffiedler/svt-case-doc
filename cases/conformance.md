# Conformance Tests

## Doc

* [conformance@svt](https://github.com/openshift/svt/tree/master/conformance)
* [extended-test@oc-origin](https://github.com/openshift/origin/tree/master/test/extended)
* [e2e-test@k8s](https://github.com/kubernetes/community/blob/master/contributors/devel/e2e-tests.md)

## Bash wrapper
Check the steps in [conformance readme](https://github.com/openshift/svt/tree/master/conformance)
to see if all the requirements are satisfied.

```sh
# ./svt/conformance/svt_conformance.sh
```


## Manual steps

### Install atomic-openshift-tests (Optional)
The rpm should be installed already by [image_provisioner](https://github.com/openshift/svt/blob/master/image_provisioner/playbooks/roles/openshift-package-install/tasks/main.yaml).

```sh
# yum install atomic-openshift-tests
# yum info atomic-openshift-tests
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Installed Packages
Name        : atomic-openshift-tests
Arch        : x86_64
Version     : 3.6.172.0.0
Release     : 1.git.0.6c797dc.el7
Size        : 156 M
Repo        : installed
From repo   : aos
Summary     : Origin Test Suite
URL         : https://github.com/openshift/origin
License     : ASL 2.0
Description : Origin Test Suite

```

### Enable master schedulable

```sh
# oc adm manage-node --schedulable=true ip-172-31-5-81.us-west-2.compute.internal
```

### Run the test
It is NOT clear (to me) where <code>KUBE_REPO_ROOT</code> and <code>EXTENDED_TEST_PATH</code>
are used. Seems NOT necessary to clone the origin repo either.


```sh
# KUBECONFIG=/etc/origin/master/admin.kubeconfig \
    TEST_REPORT_DIR=/tmp TEST_REPORT_FILE_NAME=svt-parallel \
    go/bin/ginkgo -v "-focus=EmptyDir|Conformance" "-skip=Serial|Flaky|Disruptive|Slow" \
    -p -nodes 5  /usr/libexec/atomic-openshift/extended.test
```

[Result](https://privatebin-it-iso.int.open.paas.redhat.com/?dd85b89ee13029d5#pD+2daSQU+xA+D7mDPK8WGoAIPB2u1X0eINqr1PruGQ=) on Aug 2017.
