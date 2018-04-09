# [K8S Dev](https://github.com/kubernetes/community/tree/master/contributors/devel)

## [Set up dev. env.](https://github.com/kubernetes/community/blob/master/contributors/devel/development.md)

Fedora 25:

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-7c25e604     --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 60}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fedora25-k8s-dev\"}]}]"
```

## [Build with docker](https://github.com/kubernetes/community/blob/master/contributors/devel/development.md#building-kubernetes-with-docker)

```sh
$ sudo dnf install git tree

###install docker: https://docs.docker.com/engine/installation/linux/docker-ce/fedora/
$ docker --version
Docker version 17.09.0-ce, build afdb6d4
```

Clone repo and set up upstream:

```sh
$ git clone https://github.com/hongkailiu/kubernetes.git
$ cd kubernetes
$ git remote add upstream https://github.com/kubernetes/kubernetes.git
$ git fetch upstream
$ git merge upstream/master
```

Build:

```sh
### This takes serveral minutes
$ build/run.sh make
### Check out the resulting files
$ tree _output/
```

## [Run Test](https://github.com/kubernetes/community/blob/master/contributors/devel/testing.md)

## [Build on local shell](https://github.com/kubernetes/community/blob/master/contributors/devel/development.md#building-kubernetes-on-a-local-osshell-environment)

Install `golang` [via dnf](../origin/README.md#prerequisites).

```sh
### https://github.com/kubernetes/kubernetes#to-start-developing-kubernetes
$ go version
go version go1.9.2 linux/amd64
```

Install `etcd`: follow [those steps](https://github.com/kubernetes/community/blob/master/contributors/devel/testing.md#install-etcd-dependency)

```sh

```


## Reference

[1]. https://dzone.com/articles/easy-step-by-step-local-kubernetes-source-code-cha
