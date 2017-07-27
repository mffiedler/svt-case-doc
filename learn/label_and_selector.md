# Labels and Slector

## Doc

[label&selector@k8s](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
[openshift blog](https://blog.openshift.com/use-of-selectors-to-get-pods-on-desired-nodes/)


## Apply to metrics

### Nodes

```sh
# oc get node -l region=infra --show-labels  
NAME                                          STATUS    AGE       VERSION             LABELS
ip-172-31-1-223.us-west-2.compute.internal    Ready     6d        v1.6.1+5115d708d7   ...,metrics=cassandra,region=infra,...
ip-172-31-10-125.us-west-2.compute.internal   Ready     6d        v1.6.1+5115d708d7   ...,metrics=hawkular,region=infra,...
ip-172-31-11-29.us-west-2.compute.internal    Ready     6d        v1.6.1+5115d708d7   ...,metrics=heapster,region=infra,...
```


Target

```sh
# oc get pods -o wide
NAME                         READY     STATUS    RESTARTS   AGE       IP             NODE
hawkular-cassandra-1-jh44z   1/1       Running   0          29m       172.20.0.31    ip-172-31-1-223.us-west-2.compute.internal
hawkular-metrics-lj4rz       1/1       Running   0          28m       172.22.0.31    ip-172-31-10-125.us-west-2.compute.internal
heapster-9vvkh               1/1       Running   0          10m       172.21.0.224   ip-172-31-11-29.us-west-2.compute.internal
```

```sh
# oc get node -l region=infra --show-labels  
```
