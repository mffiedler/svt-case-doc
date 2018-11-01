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
export PATH=$PATH:$GOPATH/bin

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

### Build release: NOT working yet

Clone repo:

```sh
### using go get command to clone repo instead of git-clone command
$ go get github.com/openshift/origin
$ cd ~/repo/go/src/github.com/openshift/origin/
```

Build release

```sh
### Update on 20181101 with fedora 26
$ go version
go version go1.10.3 linux/amd64

master
eb939d74d11c246fe2c12cc766ef87583c1c87b1
make: Y
result: $ ll _output/local/bin/linux/amd64/

make build-rpms: N
sudo make build-rpms: Y
$ ll _output/local/releases/rpms/

sudo make build-images: N

./hack/build-local-images.py: Yes

sudo make release: N

```

### Run unit test

```sh
$ hack/test-go.sh -v
```

### Run integration test
TODO

### Run extended Tests

See [extended_test.md](extended_test.md).

## Dev

### Code format

Before commit:

```sh
### https://blog.golang.org/go-fmt-your-code
# go fmt <any_changed_file.go>
```

### Ping owners

* `@owner_github_id` in the OWNER list
* join the IRC channel `#openshift-dev@freenode` and ping/harass if having waited for sometime
    * via browser: [webchat.freenode.net](https://webchat.freenode.net/)
    * via pidgin: [HOWTO](https://adammonsen.com/post/329/)
