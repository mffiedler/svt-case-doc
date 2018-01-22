Original of Openshift

## Build
See [HACKING.md](https://github.com/openshift/origin/blob/master/HACKING.md)

Set up go-lang env. (check the required go-lange version [here](https://github.com/kubernetes/community/blob/master/contributors/devel/development.md#building-kubernetes-on-a-local-osshell-environment)):
```sh
### Method1
### add repo as described here: https://go-repo.io/
$ sudo rpm --import https://mirror.go-repo.io/fedora/RPM-GPG-KEY-GO-REPO
$ curl -s https://mirror.go-repo.io/fedora/go-repo.repo | sudo tee /etc/yum.repos.d/go-repo.repo
$ sudo dnf install -y golang
$ go version
go version go1.9.2 linux/amd64

### Method2: Not working
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

$ source ~/.bash_profile
```

Install dependencies:

```sh
### check on https://github.com/openshift/origin/blob/master/CONTRIBUTING.adoc
$ sudo dnf install golang golang-race make gcc zip mercurial krb5-devel bsdtar bc rsync bind-utils file jq tito createrepo openssl gpgme gpgme-devel libassuan libassuan-devel
```

```sh
[fedora@ip-172-31-40-12 openshift]$ git clone https://github.com/openshift/origin.git
$ docker --version 
Docker version 17.09.0-ce, build afdb6d4
```

## Extended Tests of Origin

See [extended_test.md](extended_test.md).
