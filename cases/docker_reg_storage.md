# Storage Test for docker registery

* Push test: Run concurrent build test.
* Pull test: Run scale up/down test.

## Case 1: PVC backed up by gp2 volume

Cluster: 1 master, 1 infra, 2 compute nodes where computes are equipped with 300g IOPS (2000) docker device (/dev/sdb).

Set up gp2 PVC as registery storage volume: [steps](../learn/docker_registry.md#use-filesystem-driver-for-docker-registry): the PVC size is 1000G is to ensure that we have enough burst balance for the device.

## Case 2: PVC backed up by glusterfs volume

Cluster: 1 master, 1 infra, 2 compute nodes where computes are equipped with 300g IOPS (2000) docker device (/dev/sdb).

4 cns nodes (m2.4xlarge): 3 glusterfs, 1 heketi (block-provisioner disabled): 1300g xvdf (gp2) and 150g PVC for docker registry.

## Restrict nodes for build pods (if needed)

[Set up by master-config](https://docs.openshift.org/latest/install_config/build_defaults_overrides.html#install-config-build-defaults-overrides):

```sh
# vi /etc/origin/master/master-config.yaml
admissionConfig:
  pluginConfig:
    BuildDefaults:
      configuration:
        apiVersion: v1
        env: []
        nodeSelector:
          build: build
        kind: BuildDefaultsConfig

# systemctl restart atomic-openshift-master*
```

Verify this by triggering a round of builds and then

```sh
# oc get pod --all-namespaces -o wide | grep "\-build"
### All build pods are pending
# oc label node ip-172-31-3-115.us-west-2.compute.internal build=build
# oc get pod --all-namespaces -o wide | grep "\-build"
### All build pods are running on the above labelled node

```

## Checking before running concurrent builds

* Enough space on <code>xdva2</code> and <code>xdvb</code>
* Enough space on <code>xdvf</code>, instance types for cns nodes
* install CNS with pods running on the right nodes
* create PVC with the right storage class and using it with docker registry
* start pbench

## Concurrent builds

[Start pbench](../learn/pbench.md#use-pbench-in-the-test)

Prepare the project with cluster-loader:

```sh
# cd svt/openshift_performance/ci/scripts/
# ../../../openshift_scalability/cluster-loader.py -v -f ../content/conc_builds_nodejs.yaml 
# ../../ose3_perf/scripts/build_test.py -z -n 2 -a
```

## Check results

Watching the output of the above build script. Compare the succuss rate of builds and pbench data, eg, in case of gp2, [IOPS on the device xvdcz](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-24-121/hk-conc-scale-a/tools-default/ip-172-31-57-74.us-west-2.compute.internal/iostat/disk.html), which is the one for docker registry.

In the case of glusterfs PVC, we check the CPU and [MEM](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-4-223/hk-conc-scale-a/tools-default/ip-172-31-4-223/ip-172-31-35-129.us-west-2.compute.internal/pidstat/memory_usage.html) consupmtion of glusterfsd process, and [IOPS on the device xvdf](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-4-223/hk-conc-scale-a/tools-default/ip-172-31-4-223/ip-172-31-35-129.us-west-2.compute.internal/iostat/disk.html) on each glusterfs node. CPU and memory usage of heketi process should pretty stable in this test.

Retrieve the [results](docker_reg_storage_result.md) from the log file:

```sh
# grep "Failed builds: " /tmp/build_test.log -A5          
```


## Result

| date     | build nodes | app    | proj    | n | storage                                 | suc%                | pbench                                                                                    | oc version                      |
|----------|-------------|--------|---------|---|-----------------------------------------|---------------------|-------------------------------------------------------------------------------------------|---------------------------------|
| 20171201 | 2           | nodejs | 50      | 2 | gp2                                     | 97; 99; 98          | [ip-172-31-24-121](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-24-121/)   | 3.7.9-1.git.0.7c71a2d.el7       |
| 20171201 | 2           | nodejs | 100     | 2 | gp2                                     | 87; 74.5            | [ip-172-31-24-121](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-24-121/)   | 3.7.9-1.git.0.7c71a2d.el7       |
| 20171204 | 10          | nodejs | 250     | 2 | gp2                                     | 99.8; 99.8; 100     | [ip-172-31-23-178](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-23-178/)   | 3.7.9-1.git.0.7c71a2d.el7       |
| 20171204 | 10          | nodejs | 500     | 2 | gp2                                     | 99.9; 88.5          | [ip-172-31-23-178](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-23-178/)   | 3.7.9-1.git.0.7c71a2d.el7       |
| 20171205 | 10          | nodejs | 250     | 2 | glusterfs (3.3.0-362)                   | 99.8; 100; 99.8     | [ip-172-31-4-223](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-4-223/)     | 3.7.9-1.git.0.7c71a2d.el7       |
| 20171205 | 10          | nodejs | 500     | 2 | glusterfs (3.3.0-362)                   | 99.9; NotReady; 100 | [ip-172-31-4-223](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-4-223/)     | 3.7.9-1.git.0.7c71a2d.el7       |
| 20180425 | 10          | nodejs | 250/500 | 2 | glusterfs (3.3.1-13); heketi (3.3.1-10) | 100                 | [172-31-2-125](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-2-125/)   | 3.10.0-0.28.0.git.0.66790cb.el7 |
| 20180508 | 10          | nodejs | 500     | 6 | glusterfs (3.3.1-13); heketi (3.3.1-10) | 100; 99.8           | [172-31-55-221](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-55-221/) | 3.10.0-0.32.0.git.0.2b17fd0.el7 (with crio) |

* Note 20171204 uses Vikas' modification on node-config.yaml.
* 20180508: 750 (n=2): 96%; 1000 (n=2): ?%

