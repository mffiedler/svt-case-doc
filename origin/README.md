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

### Run unit test

```sh
$ hack/test-go.sh -v
```

### Run integration test
TODO

### Run extended Tests: ongoing

See [extended_test.md](extended_test.md).

Build:

```sh
$ make build WHAT=test/extended/extended.test
```

Run extended test against an existing cluster:

```sh
$ KUBECONFIG=/path/to/admin.kubeconfig TEST_ONLY=true test/extended/core.sh --ginkgo.focus=<regex>
```

Run cluster-loader:

```sh
$ TODO
```
