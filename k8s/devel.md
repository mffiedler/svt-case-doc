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

Go get src:

```sh
$ go get -d k8s.io/kubernetes
$ cd $GOPATH/src/k8s.io/kubernetes
```

Install `etcd`: follow [those steps](https://github.com/kubernetes/community/blob/master/contributors/devel/testing.md#install-etcd-dependency)

```sh
$ hack/install-etcd.sh
$ echo export PATH=/home/fedora/repo/go/src/k8s.io/kubernetes/third_party/etcd:${PATH} >> ~/.bash_profile
$ source ~/.bash_profile
$ etcd --version
etcd Version: 3.1.12
Git SHA: 918698add
Go Version: go1.8.7
Go OS/Arch: linux/amd64
[fedora@ip-172-31-40-12 kubernetes]$ which etcd
~/repo/go/src/k8s.io/kubernetes/third_party/etcd/etcd
```


Build and run

See the doc: [blog](https://dzone.com/articles/easy-step-by-step-local-kubernetes-source-code-cha) and [v1-4 doc](https://kubernetes-v1-4.github.io/docs/getting-started-guides/locally/#starting-the-cluster)
It seems that this way is no longer supported in the official k8s doc.

Run a local cluster:

```sh
### https://github.com/kubernetes/kubernetes/blob/master/hack/local-up-cluster.sh#L156
$ hack/local-up-cluster.sh
```


With another terminal:

```sh
$ cluster/kubectl.sh cluster-info
Kubernetes master is running at http://localhost:8080
KubeDNS is running at http://localhost:8080/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

```

Change some code and run again as the above blog, we can see the new log entry.

Many useful information shows up in the terminal:

```sh
Local Kubernetes cluster is running. Press Ctrl-C to shut it down.

Logs:
  /tmp/kube-apiserver.log
  /tmp/kube-controller-manager.log

  /tmp/kube-proxy.log
  /tmp/kube-scheduler.log
  /tmp/kubelet.log

To start using your cluster, you can open up another terminal/tab and run:

  export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig
  cluster/kubectl.sh

Alternatively, you can write to the default kubeconfig:

  export KUBERNETES_PROVIDER=local

  cluster/kubectl.sh config set-cluster local --server=https://localhost:6443 --certificate-authority=/var/run/kubernetes/server-ca.crt
  cluster/kubectl.sh config set-credentials myself --client-key=/var/run/kubernetes/client-admin.key --client-certificate=/var/run/kubernetes/client-admin.crt
  cluster/kubectl.sh config set-context local --cluster=local --user=myself
  cluster/kubectl.sh config use-context local
  cluster/kubectl.sh

```

For example, to check k8s-api-server log which is `/tmp/kube-apiserver.log`.

