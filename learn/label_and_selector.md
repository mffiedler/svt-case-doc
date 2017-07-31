# Labels and Slector

Labels can be added on any objects. The examples on this pages uses nodes.

## Doc

* [label&selector@k8s](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
* [nodeSlector@k8s](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
* [openshift blog](https://blog.openshift.com/use-of-selectors-to-get-pods-on-desired-nodes/)


## [How to add/update/remove labels on a node](https://docs.openshift.com/enterprise/3.0/cli_reference/basic_cli_operations.html)
We can use this command to edit node on the labels part:

```sh
$ oc edit node/<nodename>
metadata:
  ...
  labels:
    region: primary
    zone: east
```

### add

```sh
# oc label node <nodename> “key=value”
```
### update

```sh
# oc label node <nodename> “key=value” --overwrite
```

### remove

```sh
# oc label node <nodename> “key=''”
```

## Apply to metrics

### Nodes
Assume that we have 3 _infra_ nodes with different labels for each component of metrics:

```sh
# oc get node -l region=infra --show-labels  
NAME                                          STATUS    AGE       VERSION             LABELS
ip-172-31-1-223.us-west-2.compute.internal    Ready     6d        v1.6.1+5115d708d7   ...,metrics=cassandra,region=infra,...
ip-172-31-10-125.us-west-2.compute.internal   Ready     6d        v1.6.1+5115d708d7   ...,metrics=hawkular,region=infra,...
ip-172-31-11-29.us-west-2.compute.internal    Ready     6d        v1.6.1+5115d708d7   ...,metrics=heapster,region=infra,...
```


### Target
The target is to deplay metrics pods on the nodes with its own label:

```sh
# oc get pods -o wide
NAME                         READY     STATUS    RESTARTS   AGE       IP             NODE
hawkular-cassandra-1-jh44z   1/1       Running   0          29m       172.20.0.31    ip-172-31-1-223.us-west-2.compute.internal
hawkular-metrics-lj4rz       1/1       Running   0          28m       172.22.0.31    ip-172-31-10-125.us-west-2.compute.internal
heapster-9vvkh               1/1       Running   0          10m       172.21.0.224   ip-172-31-11-29.us-west-2.compute.internal
```

### Node Selector
Edit rc, for example heapter and add nodeSelector:

```sh
# oc get rc heapster -o yaml | grep -i dns -A3
      dnsPolicy: ClusterFirst
      nodeSelector:
        metrics: heapster
```


## Link Service and pod

### Deploy pod by rc
