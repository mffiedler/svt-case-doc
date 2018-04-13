# oc-cli

## Install from yum/dfn
See [steps](../cases/conc-build-online.md#install-atomic-openshift-clients-35x) to configure
yum/dnf repos.

The pkg `atomic-openshift-clients` also contains `kubectl`

```sh
$ dnf repoquery -l atomic-openshift-clients | grep kubectl
Last metadata expiration check: 0:05:38 ago on Fri 13 Apr 2018 06:01:31 PM UTC.
/usr/bin/kubectl

```

## Install from binary

Download from [releases@github](https://github.com/openshift/origin/releases).

```sh
$ curl -L -O https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
$ tar -xzf openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
$ mkdir bin
$ ln -s ../openshift-origin-client-tools-v3.9.0-191fece-linux-64bit/oc oc
$ which oc
~/bin/oc
```