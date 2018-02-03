# [GoLang](https://golang.org/)

## Tutorial

* [golangbot.com](https://golangbot.com/learn-golang-series/)

## Installation

### [from binary](https://golang.org/doc/install)

```sh
$ cd ~/tool
$ wget https://dl.google.com/go/go1.9.3.linux-amd64.tar.gz
$ tar -xzf go1.9.3.linux-amd64.tar.gz
$ mv go go1.9.3
$ ln -s go1.9.3 go

### Append ~/.bashrc
...
export GOROOT=$HOME/tool/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=$HOME/repo/go
export PATH=$GOPATH/bin:$PATH

$ go version
go version go1.9.3 linux/amd64
```

### from dnf

## Cli

## IDE

### Dep. Management

### logging

* [sirupsen/logrus](https://github.com/sirupsen/logrus)
* [op/go-logging](https://github.com/op/go-logging)

### cli

* [spf13/cobra](https://github.com/spf13/cobra)

## Libs

## CICD
