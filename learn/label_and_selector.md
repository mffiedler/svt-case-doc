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
Use [rc_test.yaml](../files/rc_test.yaml) to create pod, which uses <code>docker.io/hongkailiu/svt-go:http</code>
images and create a web server.

```sh
# oc create -f /tmp/rc_test.yaml
# oc get pods -o wide --show-labels
NAME               READY     STATUS    RESTARTS   AGE       IP           NODE                                         LABELS
frontend-1-kml0x   1/1       Running   0          45m       172.20.0.3   ip-172-31-4-190.us-west-2.compute.internal   name=frontend
# curl 172.20.0.3:8080
```

_Note_ that label of pods is the value of the selector of the rc.

### Deploy svc to proxy the above pod
Use [svc_test.yaml](../files/svc_test.yaml) to create svc.

```sh
oc create -f /tmp/svc_test.yaml
# oc get svc
NAME         CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
my-service   172.26.114.211   <none>        8080/TCP   14m
# curl 172.26.114.211:8080
```

_Note_ that the selector of the svc choose pods with the _same_ label to proxy.

### Create route for the svc (optional)

```sh
# oc expose service my-service
# oc get routes
NAME         HOST/PORT                             PATH      SERVICES     PORT      TERMINATION   WILDCARD
my-service   my-service-aaa.54.214.91.134.xip.io             my-service   8080                    None
root@ip-172-31-58-73: ~ # curl my-service-aaa.54.214.91.134.xip.io
```

_Note_ that the curl command works in the public network and this shows that <code>xip.io</code> works too.

## Take [registry-console](https://docs.openshift.org/latest/install_config/registry/deploy_registry_existing_clusters.html#registry-console) to infra node

Flexy ensures the router and the docker-registry containers run on infra nodes while registry-console runs on one of the computing nodes. If we want to move it to infra-node, follow those steps:

Add <code>nodeSelector</code> to <code>dc</code> after <code>dnsPolicy: ClusterFirst</code>:

```sh
# oc edit dc registry-console
      ...
      nodeSelector:
        region: infra
        zone: default

```

After saving the dc, a new _registry-console_ pod will be deployed automatcially which replaces the existing one.

