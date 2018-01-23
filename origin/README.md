# Original of Openshift

## Prerequisites
See [HACKING.md](https://github.com/openshift/origin/blob/master/HACKING.md) and [CONTRIBUTING.adoc](https://github.com/openshift/origin/blob/master/CONTRIBUTING.adoc).

Set up go-lang env. (check the required go-lange version [here](https://github.com/kubernetes/community/blob/master/contributors/devel/development.md#building-kubernetes-on-a-local-osshell-environment)):
```sh
### Method1
### add repo as described here: https://go-repo.io/
$ sudo rpm --import https://mirror.go-repo.io/fedora/RPM-GPG-KEY-GO-REPO
$ curl -s https://mirror.go-repo.io/fedora/go-repo.repo | sudo tee /etc/yum.repos.d/go-repo.repo
$ sudo dnf install -y golang
$ go version
go version go1.9.2 linux/amd64
$ mkdir ~/repo/go
$ vi ~/.bash_profile
...
export GOPATH=$HOME/repo/go

### Method2: Not working for origin build
$ wget https://dl.google.com/go/go1.9.1.linux-amd64.tar.gz
$ tar -xzf go1.9.1.linux-amd64.tar.gz 
$ mv go go1.9.1
$ ln -s go1.9.1 go
$ ln -s $(pwd)/go/bin/go ~/bin/go
$ go version
go version go1.9.1 linux/amd64

###
$ vi ~/.bash_profile
...
export GOROOT=$HOME/tool/go
export GOPATH=$HOME/repo/go
export PATH=$PATH:$GOPATH/bin

$ source ~/.bash_profile
```

Install dependencies:

```sh
### check on https://github.com/openshift/origin/blob/master/CONTRIBUTING.adoc
$ sudo dnf install golang golang-race make gcc zip mercurial krb5-devel bsdtar bc rsync bind-utils file jq tito createrepo openssl gpgme gpgme-devel libassuan libassuan-devel

$ go get -u github.com/openshift/imagebuilder/cmd/imagebuilder
```

Install docker:

```sh
$ docker --version 
Docker version 17.09.0-ce, build afdb6d4
```

## Build

### Build release

Clone repo:

```sh
### using go get command to clone repo instead of git-clone command
$ go get github.com/openshift/origin
$ cd ~/repo/go/src/github.com/openshift/origin/
```

Build release

```sh
$ cd origin
$ make release
### Still not working
[openshift/origin-service-catalog] --> Image openshift/origin-source was not found, pulling ...
[openshift/origin-service-catalog] unable to pull image (from: openshift/origin-source, tag: latest): API error (404): {"message":"pull access denied for openshift/origin-source, repository does not exist or may require 'docker login'"}
[ERROR] PID 8550: hack/lib/constants.sh:56: `return "${result}"` exited with status 1.
[INFO] 		Stack Trace: 
[INFO] 		  1: hack/lib/constants.sh:56: `return "${result}"`
[INFO] 		  2: hack/build-images.sh:25: os::build::images
[INFO]   Exiting with code 1.
[openshift/origin-cluster-capacity] --> Image openshift/origin-source was not found, pulling ...
[openshift/origin-cluster-capacity] unable to pull image (from: openshift/origin-source, tag: latest): API error (404): {"message":"pull access denied for openshift/origin-source, repository does not exist or may require 'docker login'"}
[openshift/origin-template-service-broker] --> Image openshift/origin-source was not found, pulling ...
[openshift/origin-template-service-broker] unable to pull image (from: openshift/origin-source, tag: latest): API error (404): {"message":"pull access denied for openshift/origin-source, repository does not exist or may require 'docker login'"}
[openshift/origin-pod] --> Image openshift/origin-source was not found, pulling ...
[openshift/origin-pod] unable to pull image (from: openshift/origin-source, tag: latest): API error (404): {"message":"pull access denied for openshift/origin-source, repository does not exist or may require 'docker login'"}
[ERROR] PID 8549: hack/lib/constants.sh:56: `return "${result}"` exited with status 1.
[INFO] 		Stack Trace: 
[INFO] 		  1: hack/lib/constants.sh:56: `return "${result}"`
[INFO] 		  2: hack/build-images.sh:25: os::build::images
[INFO]   Exiting with code 1.
[ERROR] PID 8548: hack/lib/constants.sh:56: `return "${result}"` exited with status 1.
[ERROR] PID 8551: hack/lib/constants.sh:56: `return "${result}"` exited with status 1.
[INFO] 		Stack Trace: 
[INFO] 		Stack Trace: 
[INFO] 		  1: hack/lib/constants.sh:56: `return "${result}"`
[INFO] 		  1: hack/lib/constants.sh:56: `return "${result}"`
[INFO] 		  2: hack/build-images.sh:25: os::build::images
[INFO] 		  2: hack/build-images.sh:25: os::build::images
[INFO]   Exiting with code 1.
[INFO]   Exiting with code 1.
[ERROR] PID 8500: hack/lib/constants.sh:361: `wait $i` exited with status 1.
[INFO] 		Stack Trace: 
[INFO] 		  1: hack/lib/constants.sh:361: `wait $i`
[INFO] 		  2: hack/build-images.sh:25: os::build::images
[INFO]   Exiting with code 1.
[ERROR] hack/build-images.sh exited with code 1 after 00h 00m 02s
```

We can see that the RPMs are generated from "make-release": Probablly `origin-tests-*.rpm` contains extended test binary.

```sh
[fedora@ip-172-31-40-12 origin]$ ll _output/local/releases/rpms/
total 203228
-rw-rw-r--. 1 fedora fedora      191 Jan 23 15:36 local-release.repo
-rw-rw-r--. 1 fedora fedora 71353858 Jan 23 15:34 origin-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
-rw-rw-r--. 1 fedora fedora 34436274 Jan 23 15:35 origin-clients-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
-rw-rw-r--. 1 fedora fedora 11297366 Jan 23 15:36 origin-cluster-capacity-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
-rw-rw-r--. 1 fedora fedora    10346 Jan 23 15:36 origin-docker-excluder-3.9.0-0.alpha.3.121.e4baeb2.noarch.rpm
-rw-rw-r--. 1 fedora fedora    10314 Jan 23 15:36 origin-excluder-3.9.0-0.alpha.3.121.e4baeb2.noarch.rpm
-rw-rw-r--. 1 fedora fedora 32603242 Jan 23 15:35 origin-federation-services-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
-rw-rw-r--. 1 fedora fedora      191 Jan 23 15:36 origin-local-release.repo
-rw-rw-r--. 1 fedora fedora    24906 Jan 23 15:34 origin-master-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
-rw-rw-r--. 1 fedora fedora    11434 Jan 23 15:35 origin-node-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
-rw-rw-r--. 1 fedora fedora   400658 Jan 23 15:35 origin-pod-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
-rw-rw-r--. 1 fedora fedora  3685274 Jan 23 15:35 origin-sdn-ovs-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
-rw-rw-r--. 1 fedora fedora 10379094 Jan 23 15:35 origin-service-catalog-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
-rw-rw-r--. 1 fedora fedora 14391690 Jan 23 15:35 origin-template-service-broker-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
-rw-rw-r--. 1 fedora fedora 29463998 Jan 23 15:35 origin-tests-3.9.0-0.alpha.3.121.e4baeb2.x86_64.rpm
drwxrwxr-x. 2 fedora fedora     4096 Jan 23 15:36 repodata

```

### Run unit test

```sh
$ hack/test-go.sh -v
```

### Run integration test
TODO

### Run extended Tests

See [extended_test.md](extended_test.md).

There are several ways to run extended tests. Note that cluster-loader is only one of the extended tests. Our beloved cluster-loader has a [page](https://docs.openshift.com/container-platform/3.7/scaling_performance/using_cluster_loader.html) in openshift-doc.

If you want to use extended test as a tool, instead of doing development/fixing bugs of the tool, use the released PRM is the best way. Otherwise, run it from the local build or src as described below.

#### Run from released rpm
on our master, the binary for running extended tests is already installed. It came with `atomic-openshift-tests` from `aos` repo:

```sh
# yum info atomic-openshift-tests
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Installed Packages
Name        : atomic-openshift-tests
Arch        : x86_64
Version     : 3.9.0
Release     : 0.22.0.git.0.d4658fb.el7
Size        : 182 M
Repo        : installed
From repo   : aos
Summary     : Origin Test Suite
URL         : https://github.com/openshift/origin
License     : ASL 2.0
Description : Origin Test Suite

```

[Here](https://github.com/openshift/svt/blob/master/openshift_scalability/nodeVertical.sh#L25) shows how we run cluster-loader on master:

```sh
### scp admin.kubeconfig from master node
$ scp -i ~/.ssh/id_rsa_perf root@ec2-54-191-255-61.us-west-2.compute.amazonaws.com:/etc/origin/master/admin.kubeconfig /tmp/
# KUBECONFIG=/path/to/admin.kubeconfig /usr/libexec/atomic-openshift/extended.test --ginkgo.focus="Load cluster" --viper-config=$MY_CONFIG
```

#### Run from local build

Build the binary:

```sh
$ make build WHAT=test/extended/extended.test
$ ll _output/local/bin/linux/amd64/extended.test 
-rwxrwxr-x. 1 fedora fedora 180904704 Jan 23 01:53 _output/local/bin/linux/amd64/extended.test
```

Run cluster-loader: This requires `oc` command in `${PATH}`.

```sh
# KUBECONFIG=/tmp/admin.kubeconfig  _output/local/bin/linux/amd64/extended.test --ginkgo.focus="Load cluster" --viper-config=$MY_CONFIG
```

#### Run from src

Get dependencies:

```sh
$ go get github.com/onsi/ginkgo/ginkgo
$ go get github.com/onsi/gomega/...
```
Run cluster-loader: No need to install `oc` command because it will build it on the fly.

```sh
$ FOCUS='Load cluster' KUBECONFIG=/tmp/admin.kubeconfig TEST_ONLY=true test/extended/core.sh --viper-config=$MY_CONFIG
### or,
$ KUBECONFIG=/tmp/admin.kubeconfig TEST_ONLY=true test/extended/core.sh --ginkgo.focus="Load cluster" --viper-config=$MY_CONFIG
```

Run extended tests with regex of `focus`:

```sh
### The following command has not been tested yet
$ KUBECONFIG=/path/to/admin.kubeconfig TEST_ONLY=true test/extended/core.sh --ginkgo.focus=<regex>
```
