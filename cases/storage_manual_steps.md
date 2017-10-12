# Storage Test with Manual Steps

## Prepare env
Build/Pull on docker image: Optional.

On a compute node:

The image has been built and pushed to docker.io:

```sh
# #NOT Optional, otherwise need to change the dc of the pod
# docker pull docker.io/hongkailiu/centosfio:3.6.172.0.0
```

Create scc on master, label the computing node, and create test project:

```sh
# cd svt/storage/
# oc create -f content/fio-scc.json
# oc label node ip-172-31-26-174.us-west-2.compute.internal "aaa=bbb"
# oc new-project aaa
```
* Scp _id_rsa.pub_ to _/root/.ssh/_ of the computing node.
* On master: Modify _image_ and _nodeSelector_ in _content/fio-pod-pv.json_.


On master:

```sh
# oc process -p ROLE=receiver -f content/fio-pod-pv.json | oc create --namespace=aaa -f -
# #Check if the pod is running:
root@ip-172-31-6-15: ~/svt/storage # oc get pod -o wide
NAME          READY     STATUS    RESTARTS   AGE       IP           NODE
fio-1-86n8j   1/1       Running   0          7m        172.20.1.6   ip-172-31-26-174.us-west-2.compute.internal

# #Check if we can ssh to the pod via its IP:
# ssh 172.20.1.6
System is booting up. See pam_nologin(8)
Last login: Wed Aug 30 16:59:49 2017 from ip-172-20-1-1.us-west-2.compute.internal
[root@fio-1-86n8j ~]#
```

## Register pbench

On master:

```sh
# pbench-register-tool-set --label=FIO
# pbench-register-tool-set --label=FIO --remote=<compute_node_interal_host_eg_ip-172-31-59-209.us-west-2.compute.internal>
```

## Run pbench-fio

```sh
# #optional: trivial run
# pbench-fio --test-types=read --clients=172.20.1.6 --config=SEQ_IO --samples=1 --max-stddev=20 --block-sizes=4 --job-file=config/sequential_io.job

# #seq-io
# pbench-fio --test-types=read,write,rw --clients=172.20.1.6 --config=SEQ_IO --samples=3 --max-stddev=20 --block-sizes=4,128,4096 --job-file=config/sequential_io.job

# #random-io
# pbench-fio --test-types=randread,randwrite,randrw --clients=172.20.1.6 --config=RAND_IO --samples=3 --max-stddev=20 --block-sizes=4,128,4096 --job-file=config/random_io.job

```

Parameters of pbench-fio: [here](http://distributed-system-analysis.github.io/pbench/doc/agent/user-guide.html#orga6d8420).

[pbench-fio](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-fio) will ssh to the pod and run fio-server there and then use the local host to connect to (via <code>fio --client</code> command) the fio-server to send fio-jobs. See here for details on fio [sever/cleint](https://linux.die.net/man/1/fio).

## Collect and clear pbench data
On master:

```sh
# pbench-copy-results
# pbench-kill-tools
# pbench-clear-tools
# oc delete project aaa
# pbench-clear-results 
```

TODO: run the fio command used by pbench-fio.

## pbench-fio on AH

Get the compute nodes and label them as <code>type=pbench</code>:

```sh
[fedora@ip-172-31-33-174 scale-testing]$ oc get node -l region=primary
NAME                                         STATUS    AGE       VERSION
ip-172-31-13-22.us-west-2.compute.internal   Ready     52m       v1.7.0+80709908fd
ip-172-31-4-142.us-west-2.compute.internal   Ready     52m       v1.7.0+80709908fd

[fedora@ip-172-31-33-174 ~]$ oc label node ip-172-31-13-22.us-west-2.compute.internal type=pbench
[fedora@ip-172-31-33-174 ~]$ oc label node ip-172-31-4-142.us-west-2.compute.internal type=pbench
```

Then create sa (useroot) and ds (pbench-agent) as described [containerized_pbench.md](../atomic/containerized_pbench.md).

```sh
[fedora@ip-172-31-33-174 ~]$ oc get ds
NAME           DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE-SELECTOR   AGE
pbench-agent   2         2         2         2            2           type=pbench     3m
```

After the _fio_ pod is running and ssh to its IP from master works, we establish
a service for it:

```sh
[fedora@ip-172-31-33-174 storage]$ oc get pod -o wide --show-labels
NAME          READY     STATUS    RESTARTS   AGE       IP           NODE                                         LABELS
fio-1-pzxnf   1/1       Running   0          3m        172.23.0.4   ip-172-31-13-22.us-west-2.compute.internal   deployment=fio-1,deploymentconfig=fio,name=receiver,test=fio
```

