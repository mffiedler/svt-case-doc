# [K8S Dev](https://github.com/kubernetes/community/tree/master/contributors/devel)

## [Set up dev. env.](https://github.com/kubernetes/community/blob/master/contributors/devel/development.md)

Fedora 25:

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-7c25e604     --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 60}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fedora25-k8s-dev\"}]}]"
```

```sh
$ sudo dnf install git

###install docker: https://docs.docker.com/engine/installation/linux/docker-ce/fedora/
$ docker --version
Docker version 17.09.0-ce, build afdb6d4
```

## [Build from src](https://github.com/kubernetes/community/blob/master/contributors/devel/development.md#building-kubernetes-with-docker)

### Clone repo and set up upstream

```sh
$ git clone https://github.com/hongkailiu/kubernetes.git
$ git remote add upstream https://github.com/kubernetes/kubernetes.git
$ git fetch upstream
$ git merge upstream/master
```

### Docker


## [Run Test](https://github.com/kubernetes/community/blob/master/contributors/devel/testing.md)
