# Master Virt Test

We call those the "kitchen sink" test, the "everything is included" test.

## [Start pbench](../learn/pbench.md)

## Run with [cluster_loader.py](https://github.com/openshift/svt/blob/master/openshift_scalability/README.md)

```sh
# cd svt/openshift_scalability/
# ./cluster-loader.py -f config/master-vert-pv.yaml
```

## Change parameters

Run with densities of 10/15/20 projects of each application type. that would be 35/50ish/70 apps per node in a 2-computing-node cluster.

```sh
# cd svt/openshift_scalability/
# vi config/master-vert-pv.yaml
```

In total, we have 7 project types there. Increate either the number of projects or the number of templates for each type from _1_ by default, to *10*. So 10 * 7 (types) = 70 (app) which implies 70 / 2 (nodes) = 35 apps / node.

The number of running pods is bigger because some apps need 2 pods to run, e.g, mysql. Set 10 as project number and it is often to see failed build and some pods are with error.

## [pbench stats](../learn/pbench.md)
The pbench results (running 10 and 20) are available [here]().
