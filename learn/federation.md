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
# kubefed init myfed --dns-provider=aws-route53 --dns-zone-name=54.191.25.8.xip.io --etcd-persistent-storage=true --image=registry.ops.openshift.com/openshift3/ose-federation:v3.6.173.0.5-1
# kubectl config view --minify
```

_The above command (_kubefed init myfed_) did not return. After sometime, ctrl + c. It seems the expected results are created._

```sh
# oc get all -n federation-system
NAME                              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/myfed-apiserver            1         1         1            1           2h
deploy/myfed-controller-manager   1         1         1            1           2h

NAME                     HOST/PORT                                                   PATH      SERVICES          PORT      TERMINATION   WILDCARD
routes/myfed-apiserver   myfed-apiserver-federation-system.0804-1xd.qe.rhcloud.com             myfed-apiserver   https                   None

NAME                  CLUSTER-IP     EXTERNAL-IP        PORT(S)         AGE
svc/myfed-apiserver   172.24.49.14   a3bfe90c37943...   443:32091/TCP   2h

NAME                                     DESIRED   CURRENT   READY     AGE
rs/myfed-apiserver-1486087934            1         1         1         1h
rs/myfed-apiserver-427616395             0         0         0         2h
rs/myfed-controller-manager-3358661013   1         1         1         2h

NAME                                           READY     STATUS    RESTARTS   AGE
po/myfed-apiserver-1486087934-6dd97            2/2       Running   0          1h
po/myfed-controller-manager-3358661013-wj4lr   1/1       Running   0          2h

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
# export CLUSTER1_CONTEXT=default/ip-172-31-11-86-us-west-2-compute-internal:8443/system:admin
# export HOST_CONTEXT=${CLUSTER1_CONTEXT}
# kubefed join cluster1 --cluster-context=${CLUSTER1_CONTEXT} --host-cluster-context=${HOST_CONTEXT} --context=myfed
```

### Check cluster1

```sh
# oc get cluster --context=myfed
NAME       STATUS    AGE
cluster1   Ready     21s

```

### Join cluster2

There must be a context for <code>cluster2</code> in the config on <code>cluster1</code>.
To this purpose, we create _redhat_ user on <code>cluster2</code> and make it an admin.

TODO need to know how to create system:admin context. Some doc is [here](https://docs.openshift.org/latest/cli_reference/manage_cli_profiles.html).

On master of <code>cluster1</code>:

```sh
# oc login https://ec2-54-190-19-72.us-west-2.compute.amazonaws.com:8443 --token=ueRzBrmTFkas9urDKkJztS2p1JjyfmMx2TUHAEdMp7U
# # change back to system:admin on cluster2
# oc config use-context default/ip-172-31-11-86-us-west-2-compute-internal:8443/system:admin
# # find out the name of context for redhat of cluster1
# oc config view
# export CLUSTER2_CONTEXT=default/ec2-54-190-19-72-us-west-2-compute-amazonaws-com:8443/redhat
# kubefed join cluster2 --cluster-context=${CLUSTER2_CONTEXT} --host-cluster-context=${HOST_CONTEXT} --context=myfed
```

### Check cluster2

```sh
# oc get cluster --context=myfed
NAME       STATUS    AGE
cluster1   Ready     1h
cluster2   Ready     28m

```

### Distribute pods to clusters

TODO
