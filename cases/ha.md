

# HA cluster
If performance is not under consideration, Use _t2.medium_ as instance type.

| role  |  number  |
|---|---|
| lb (master) | 1 |
| master   |  3 |
| etcd  | 3  |
| infra  | 2  |
| computing-nodes  | 2  |

## lb

HAProxy is running

```sh
root@<host>: ~ # ps -ef | grep haproxy
root      16444      1  0 09:03 ?        00:00:00 /usr/sbin/haproxy-systemd-wrapper -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid
haproxy   16445  16444  0 09:03 ?        00:00:00 /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid -Ds
haproxy   16446  16445  0 09:03 ?        00:00:05 /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid -Ds
```

## nodes

get nodes

```sh
NAME                                          STATUS                     AGE       VERSION             LABELS
<host>    Ready                      2h        v1.6.1+5115d708d7   ...,region=infra,zone=default
<host>   Ready,SchedulingDisabled   2h        v1.6.1+5115d708d7   ...,region=infra,zone=default
<host>   Ready,SchedulingDisabled   2h        v1.6.1+5115d708d7   ...,region=infra,zone=default
<host>    Ready                      2h        v1.6.1+5115d708d7   ...,region=primary,zone=default
<host>    Ready                      2h        v1.6.1+5115d708d7   ...,region=infra,zone=default
<host>     Ready,SchedulingDisabled   2h        v1.6.1+5115d708d7   ...,region=infra,zone=default
<host>     Ready                      2h        v1.6.1+5115d708d7   ...,region=primary,zone=default
<host>   Ready                      2h        v1.6.1+5115d708d7   ...,region=primary,zone=default
```

where _STATUS=Ready,SchedulingDisabled_ indidates the host is a master, _region=primary_ in _LABELS_ implies it is a computing node.

Nodes of ectd and lb are not in the return of the above command.

## upscale router and registery (optional)
```sh
oc scale --replicas=2 dc/docker-registry dc/router
```

## pods

get pods

```sh
root@<host>: ~ # oc get pods -o wide
NAME                       READY     STATUS    RESTARTS   AGE       IP             NODE
docker-registry-1-g316f    1/1       Running   0          2h        <ip>     <host>
docker-registry-1-k81j9    1/1       Running   0          2h        <ip>     <host>
registry-console-1-2zdzx   1/1       Running   0          2h        <ip>     <host>
router-1-2psc9             1/1       Running   0          2h        <ip>   <host>
router-1-st4tc             1/1       Running   0          2h        <ip>   <host>
```

where router and registery pods should be deployed on non-master infra-nodes.

## master configuration

### check defaultNodeSelector

```sh
root@<host>: ~ # grep -i selector -A 0 -B 1 /etc/origin/master/master-config.yaml 
projectConfig:
  defaultNodeSelector: "region=primary"
```

### check defaultNodeSelector

```sh
root@<host>: ~ # grep -i selector -A 0 -B 1 /etc/origin/master/master-config.yaml 
projectConfig:
  defaultNodeSelector: "region=primary"
```

### check masterPublicURL (top level)

```sh
root@<host>: ~ # grep -i masterPublicUrl /etc/origin/master/master-config.yaml | grep -v " master"
masterPublicURL: https://<lb_host>:8443
```

where <code><lb_host></code> should be _public-host_ of the instance which has _lb_.

### check etcd config

```sh
root@<host>: ~ # grep -i etcdClientInfo -A 7 /etc/origin/master/master-config.yaml 
etcdClientInfo:
  ca: master.etcd-ca.crt
  certFile: master.etcd-client.crt
  keyFile: master.etcd-client.key
  urls:
    - https://<etcd_host>:2379
    - https://<etcd_host>:2379
    - https://<etcd_host>:2379
```

### check master service

```sh
root@<host>: ~ # systemctl status atomic-openshift-master*
● atomic-openshift-master-controllers.service - Atomic OpenShift Master Controllers
   Loaded: loaded (/usr/lib/systemd/system/atomic-openshift-master-controllers.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2017-07-05 09:26:13 EDT; 3h 41min ago
   ...
● atomic-openshift-master-api.service - Atomic OpenShift Master API
   Loaded: loaded (/usr/lib/systemd/system/atomic-openshift-master-api.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2017-07-05 09:23:43 EDT; 3h 44min ago
```

### check etcd service

```sh
root@<host>: ~ # systemctl status etcd
● etcd.service - Etcd Server
   Loaded: loaded (/usr/lib/systemd/system/etcd.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2017-07-05 09:03:13 EDT; 5h 43min ago
```

## Determine which master-controller is active

On 3.10 cluster:

```sh
# oc get pod -n kube-system | grep controllers
master-controllers-ip-172-31-0-122.us-west-2.compute.internal   1/1       Running   0          2h
master-controllers-ip-172-31-36-53.us-west-2.compute.internal   1/1       Running   0          2h
master-controllers-ip-172-31-9-37.us-west-2.compute.internal    1/1       Running   0          2h
```

Mike's way:

Open 3 terminal, each of the watches a controller's log:

```sh
# oc logs -f -n kube-system master-controllers-XXX
```

Then,

```sh
# oc new-project aaa
```

The relevant log showed up only in log of `master-controllers-ip-172-31-9-37.us-west-2.compute.internal`
```
I0605 14:32:56.707674       1 vnids.go:114] Allocated netid 12717210 for namespace "aaa"
```

So the active controller is on `ip-172-31-9-37.us-west-2.compute.internal`.

That coincides with

```sh
# oc describe cm kube-controller-manager
Name:         kube-controller-manager
Namespace:    kube-system
Labels:       <none>
Annotations:  control-plane.alpha.kubernetes.io/leader={"holderIdentity":"ip-172-31-9-37.us-west-2.compute.internal_43f27faa-64d5-11e8-bf97-022d83e946d0","leaseDurationSeconds":15,"acquireTime":"2018-05-31T13:19:36...

Data
====
Events:  <none>
```

Note that cm `kube-scheduler` and `openshift-master-controllers` stores a different node:

```sh
# oc describe cm kube-scheduler openshift-master-controllers
Name:         kube-scheduler
Namespace:    kube-system
Labels:       <none>
Annotations:  control-plane.alpha.kubernetes.io/leader={"holderIdentity":"ip-172-31-0-122.us-west-2.compute.internal_440a1aae-64d5-11e8-9d7a-02b8a20a1d1c","leaseDurationSeconds":15,"acquireTime":"2018-05-31T13:19:4...

Data
====
Events:  <none>


Name:         openshift-master-controllers
Namespace:    kube-system
Labels:       <none>
Annotations:  control-plane.alpha.kubernetes.io/leader={"holderIdentity":"ip-172-31-0-122.us-west-2.compute.internal","leaseDurationSeconds":15,"acquireTime":"2018-05-31T13:19:36Z","renewTime":"2018-05-31T15:39:59Z...

Data
====
Events:  <none>

```
