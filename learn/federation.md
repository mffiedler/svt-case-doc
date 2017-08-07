# Federation

## Doc
* [federation@k8s](https://kubernetes.io/docs/tasks/federation/federation-service-discovery/)
* [cli: kubefed](https://kubernetes.io/docs/admin/kubefed/)
* Deshuai Ma: [GCE](https://github.com/mdshuai/tools/blob/master/k8s/docs/deploy-federation-gce.md) and [AWS](https://github.com/mdshuai/tools/blob/master/k8s/docs/deploy-federation-ec2.md)
* [Kelsey Hightower](https://github.com/kelseyhightower/kubernetes-cluster-federation)

## Prepare 2 clusters

Get 2 clusters by (Flexy](flexy.md). The following commands are executed by default on master of cluster 1 unless it says explicity otherwise.

_Note_ that all-in-one environment did not work for this test yet (tried with --etcd-persistent-storage=false/true): pods are with errors. Suspicious points:

* did not set up aws env right?
* etcd service is not installed?

## Check kubefed command (optional)
It should be installed with openshift.

```sh
# which kubefed
/usr/bin/kubefed
```

## Pull ose-federation image (optional)
E.g.,

```sh
# curl -s https://registry.ops.openshift.com/v2/openshift3/ose-federation/tags/list | jq ".tags" | sort -V -r | sed -n 3p | sed 's/.$//'
  "v3.6.173.0.5-1"
# curl -s https://registry.ops.openshift.com/v2/openshift3/ose-federation/tags/list | jq ".name"
"openshift3/ose-federation"
```

So the latest <code>image</code> is <code>registry.ops.openshift.com/openshift3/ose-federation:v3.6.173.0.5-1</code>

```sh
# docker pull registry.ops.openshift.com/openshift3/ose-federation:v3.6.173.0.5-1
```

## Initialize a federation control plane

```sh
# #This command will return in about 2 mins. No need to panic. ^_^
# kubefed init myfed --dns-provider=aws-route53 --dns-zone-name=54.244.59.49.xip.io \
    --etcd-persistent-storage=true --image=registry.ops.openshift.com/openshift3/ose-federation:v3.6.173.0.5-1
Federation API server is running at: a93b5b18e7b9d11e78f980239ac70231-715675010.us-west-2.elb.amazonaws.com
# #check created context (cluster: myfed) and user (name: myfed) by the above command
# oc config get-contexts | grep myfed
# #check project (federation-system) created 
# oc get all -n federation-system 
NAME                              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/myfed-apiserver            1         1         1            1           13m
deploy/myfed-controller-manager   1         1         1            1           13m

NAME                  CLUSTER-IP      EXTERNAL-IP        PORT(S)         AGE
svc/myfed-apiserver   172.26.241.52   a93b5b18e7b9d...   443:31901/TCP   14m

NAME                                     DESIRED   CURRENT   READY     AGE
rs/myfed-apiserver-427616395             1         1         1         13m
rs/myfed-controller-manager-3914078672   1         1         1         13m

NAME                                           READY     STATUS    RESTARTS   AGE
po/myfed-apiserver-427616395-wkljq             2/2       Running   0          13m
po/myfed-controller-manager-3914078672-ql54h   1/1       Running   2          13m

```

## Join cluster

### Some setup

```sh
# oadm --namespace federation-system policy add-role-to-user admin system:serviceaccount:federation-system:default
# oadm --namespace federation-system policy add-role-to-user admin system:serviceaccount:federation-system:federation-controller-manager
# oadm policy add-scc-to-user anyuid system:serviceaccount:federation-system:deployer -n federation-system
# oadm policy add-scc-to-user anyuid system:serviceaccount:federation-system:default -n federation-system
# oc patch deployment myfed-apiserver -n federation-system -p '{"spec": {"template": {"spec": {"securityContext": {"runAsUser": 0}}}}}'
```

### Join cluster1

```sh
# export CLUSTER1_CONTEXT=default/ip-172-31-56-203-us-west-2-compute-internal:8443/system:admin
# export HOST_CONTEXT=${CLUSTER1_CONTEXT}
# kubefed join cluster1 --cluster-context=${CLUSTER1_CONTEXT} --host-cluster-context=${HOST_CONTEXT} --context=myfed
cluster "cluster1" created
# #Check cluster1
# oc get cluster --context=myfed
NAME       STATUS    AGE
cluster1   Ready     56s

```

### Join cluster2

There must be a context for <code>cluster2</code> in the config on <code>cluster1</code>.
To this purpose, we create _redhat_ user on <code>cluster2</code> and make it an admin.

TODO need to know how to create system:admin context. Some doc is [here](https://docs.openshift.org/latest/cli_reference/manage_cli_profiles.html).

On master of <code>cluster1</code>:

```sh
# oc login https://ec2-54-201-8-244.us-west-2.compute.amazonaws.com:8443 -u redhat -p <secret>
# #change back to system:admin on cluster1
# oc config use-context default/ip-172-31-11-86-us-west-2-compute-internal:8443/system:admin
# #find out the name of context for redhat of cluster2
# # oc config get-contexts | grep redhat
# export CLUSTER2_CONTEXT=default/ec2-54-201-8-244-us-west-2-compute-amazonaws-com:8443/redhat
# kubefed join cluster2 --cluster-context=${CLUSTER2_CONTEXT} --host-cluster-context=${HOST_CONTEXT} --context=myfed
cluster "cluster2" created
# #Check cluster2
# oc get cluster --context=myfed
NAME       STATUS    AGE
cluster1   Ready     11m
cluster2   Ready     48s

```

### Distribute pods to clusters

TODO
