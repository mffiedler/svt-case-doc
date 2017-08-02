# Node Vertical Test
Node vertical test is to test how many pods in a single project the cluster can scale up to.

## Jenkins job

[SVT_Scale_NodeVerticalTest_Test_Client](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/SVT_Scale_NodeVerticalTest_Test_Client/): This job uses [pbench-controller] to generate a testing/client node beside the cluster. It is expected we run the test on this node instead of master.

## Manual steps

### Move registry console to infra node (optional)
See [here](../learn/label_and_selector.md) for details.

### [Start pbench](../learn/pbench.md)

### Run with [cluster_loader.py](https://github.com/openshift/svt/blob/master/openshift_scalability/README.md)

```sh
# cd svt/openshift_scalability/
# ./cluster-loader.py -f config/nodeVertical.yaml
```
Check if all-pods, 500 by default, are created and running without errors.

Stop bench and copy its results as usually.

### pbench stats
Check for CPU and memory of the computing nodes.

Here is an example of [pbench results](TODO).
