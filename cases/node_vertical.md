# Node Vertical Test
Node vertical test is to test how many pods in a single project the cluster can scale up to.

## Jenkins job
TODO

## Manual steps

### Move registry console to infra node (optional)
See [here](../learn/label_and_selector.md) for details.

### [Start pbench](../learn/pbench.md)

### Run with [cluster_loader.py](https://github.com/openshift/svt/blob/master/openshift_scalability/README.md)

```sh
# cd svt/openshift_scalability/
# ./cluster-loader.py -f config/nodeVertical.yaml
```
