# Storage Test for docker registery

* Push test: Run concurrent build test.
* Pull test: Run scale up/down test.

## Case 1: PVC backed up by gp2 volume

Cluster: 1 master, 1 infra, 2 compute nodes where computes are equipped with 300g IOPS (2000) docker device (/dev/sdb).

Set up gp2 PVC as registery storage volume: [steps](../learn/docker_registry.md#use-filesystem-driver-for-docker-registry): the PVC size is 1000G is to ensure that we have enough burst balance for the device.

## Case 2: PVC backed up by glusterfs volume: TODO

Cluster: 1 master, 1 infra, 2 compute nodes where computes are equipped with 300g IOPS (2000) docker device (/dev/sdb).

4 cns nodes (m2.4xlarge): 3 glusterfs, 1 heketi (block-provisioner disabled): 1000g xvdf (gp2) and 300 PVC for docker registry.

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

## Concurrent builds

[Start pbench](../learn/pbench.md#use-pbench-in-the-test)

Prepare the project with cluster-loader:

```sh
# cd svt/openshift_performance/ci/scripts/
# ../../../openshift_scalability/cluster-loader.py -v -f ../content/conc_builds_nodejs.yaml 
# ../../ose3_perf/scripts/build_test.py -z -n 2 -a
```

Watching the output of the above build script. Compare the succuss rate of builds and pbench data, eg, [IOPS on the device xvdcz](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-24-121/hk-conc-scale-a/tools-default/ip-172-31-57-74.us-west-2.compute.internal/iostat/disk.html), which is the one for docker registry.

Retrieve the results from the log file:

```sh
# grep "Failed builds: " /tmp/build_test.log -A5          
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Failed builds: 0
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Invalid builds: 1
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Good builds included in stats: 499
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Average build time, all good builds: 122
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Minimum build time, all good builds: 48
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Maximum build time, all good builds: 165
--
2017-12-04 18:44:02,373 - build_test - MainThread - INFO - Failed builds: 1
2017-12-04 18:44:02,373 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-04 18:44:02,374 - build_test - MainThread - INFO - Good builds included in stats: 499
2017-12-04 18:44:02,374 - build_test - MainThread - INFO - Average build time, all good builds: 118
2017-12-04 18:44:02,374 - build_test - MainThread - INFO - Minimum build time, all good builds: 47
2017-12-04 18:44:02,374 - build_test - MainThread - INFO - Maximum build time, all good builds: 164
--
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Failed builds: 0
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Good builds included in stats: 500
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Average build time, all good builds: 114
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Minimum build time, all good builds: 44
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Maximum build time, all good builds: 165
--
2017-12-04 19:51:10,432 - build_test - MainThread - INFO - Failed builds: 1
2017-12-04 19:51:10,432 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-04 19:51:10,432 - build_test - MainThread - INFO - Good builds included in stats: 999
2017-12-04 19:51:10,433 - build_test - MainThread - INFO - Average build time, all good builds: 205
2017-12-04 19:51:10,433 - build_test - MainThread - INFO - Minimum build time, all good builds: 44
2017-12-04 19:51:10,433 - build_test - MainThread - INFO - Maximum build time, all good builds: 380


```


## Result

| date     | build nodes | app    | proj | n | storage | suc%            | pbench                                                                                  | oc version                |
|----------|-------------|--------|------|---|---------|-----------------|-----------------------------------------------------------------------------------------|---------------------------|
| 20171201 | 2           | nodejs | 50   | 2 | gp2     | 97; 99; 98      | [ip-172-31-24-121](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-24-121/) | 3.7.9-1.git.0.7c71a2d.el7 |
| 20171201 | 2           | nodejs | 100  | 2 | gp2     | 87; 74.5        | [ip-172-31-24-121](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-24-121/) | 3.7.9-1.git.0.7c71a2d.el7 |
| 20171204 | 10          | nodejs | 250  | 2 | gp2     | 99.8; 99.8; 100 | [ip-172-31-23-178](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-23-178/) | 3.7.9-1.git.0.7c71a2d.el7 |
|          |             |        |      |   |         |                 |                                                                                         |                           |
|          |             |        |      |   |         |                 |                                                                                         |                           |

Note 20171204 uses Vikas' modification on node-config.yaml.
