# Network Test

## Jenkins job

[SVT_Network_Performance_Test](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/SVT_Network_Performance_Test/)


## Manual step

### Key file
The <code>id_rsa.pub</code> can be downloaded from the above Jenkins job.

```sh
# scp id_rsa.pub root@${OS_MASTER}:/root/svt/networking/synthetic/id_rsa.pub
```

### Configuration
On master:

#### [Rmove default project node selector](https://docs.openshift.org/latest/admin_guide/managing_projects.html#using-node-selectors)
The test will use <code>nodeSelector</code> to create pods in specific nodes.

```sh
# vi /etc/origin/master/master-config.yaml
...
projectConfig:
  defaultNodeSelector: ""
...

# systemctl restart atomic-openshift-master
```

Otherwise, pods could not be created:

```sh
# oc get event
LASTSEEN   FIRSTSEEN   COUNT     NAME           KIND                    SUBOBJECT   TYPE      REASON         SOURCE                   MESSAGE
1m         5m          17        uperf-sender   ReplicationController               Warning   FailedCreate   replication-controller   Error creating: pods "" is forbidden: pod node label selector conflicts with its project node label selector
```

#### Schedulable master node (This part is now in the bash wrapper)

```sh
# oc edit node ip-172-31-62-96.us-west-2.compute.internal
    schedulable=true
```

or,

```sh
oc adm manage-node --schedulable=false ip-172-31-62-96.us-west-2.compute.internal
```

### Bash wrapper

<code>svt/networking/synthetic/start-network-test.sh</code>

### Python script

On master:

```sh
# cd svt/networking/synthetic
# python network-test.py --help
usage: network-test.py [-h] [-v OS_VERSION] -m TEST_MASTER
                       [-n [TEST_NODES [TEST_NODES ...]]]
                       [-p [POD_NUMBERS [POD_NUMBERS ...]]]
                       {podIP,svcIP,nodeIP}

positional arguments:
  {podIP,svcIP,nodeIP}

optional arguments:
  -h, --help            show this help message and exit
  -v OS_VERSION, --version OS_VERSION
                        OpenShift version
  -m TEST_MASTER, --master TEST_MASTER
                        OpenShift master node
  -n [TEST_NODES [TEST_NODES ...]], --node [TEST_NODES [TEST_NODES ...]]
                        OpenShift node
  -p [POD_NUMBERS [POD_NUMBERS ...]], --pods [POD_NUMBERS [POD_NUMBERS ...]]
                        Sequence of pod numbers to test
```

Eg,

```sh
# python network-test.py podIP --master ip-172-31-62-96.us-west-2.compute.internal --pods 1
# python network-test.py svcIP --master ip-172-31-62-96.us-west-2.compute.internal \
    --node ip-172-31-54-185.us-west-2.compute.internal ip-172-31-16-99.us-west-2.compute.internal --pods 2
```

Playbook <code>\<pod|node|svc\>-ip-test-setup.yaml</code> will be executed
accordingly where pbench data will be collected.

### Pbench result

An example of pbench data is [here](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-62-96/).

TODO what to check on pbench data.
