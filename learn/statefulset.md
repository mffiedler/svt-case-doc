# StatefulSets

## Doc

* [statefulset@k8s](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
* [stateful-app@k8s](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/)
* [stateful-example@oc](https://github.com/openshift/origin/tree/master/examples/statefulsets)

## Usage

* Fixed network identity
* Fixed storage
* Order start/termination order

## Practice stateful app in OC cluster
Run the following command if we use examples () from the above k8s doc:

```sh
oadm policy add-scc-to-user anyuid -z default
```

Note that the following command did not work yet in the test:

```sh
# kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate"}}}'
statefulset "web" not patched
```

Test is done till <code>Staging an Update</code> section. Leave the rest as TODO for the moment.

## Use oc template
Here we use probably a more realistic example: 2 replicas in <code>statefulset</code> share volumes.

Prepare an nfs-pvc named <code>pvc-nfs</code> as described [here](storage.md).

Use [sts-template.json](../files/sts-template.json) to create statefulset:

```sh
# oc process -f sts-template.json | oc create -f -
```

Check volume on each pod:

```sh
# oc volumes po/web-0
pods/web-0
  pvc/pvc-nfs (allocated 5GiB) as www
    mounted at /mydata
  secret/default-token-gcldn as default-token-gcldn
    mounted at /var/run/secrets/kubernetes.io/serviceaccount
# oc volumes po/web-1
pods/web-1
  pvc/pvc-nfs (allocated 5GiB) as www
    mounted at /mydata
  secret/default-token-gcldn as default-token-gcldn
    mounted at /var/run/secrets/kubernetes.io/serviceaccount
```

Expose the service and verify load-balencing:

```sh
# oc expose svc/nginx
route "nginx" exposed
# oc get route 
NAME      HOST/PORT                                    PATH      SERVICES   PORT      TERMINATION   WILDCARD
nginx     nginx-svt-test-nfs.0810-5as.qe.rhcloud.com             nginx      web                     None

# It show different IPs of the pods
$ curl nginx-svt-test-nfs.0810-5as.qe.rhcloud.com
{"version":"0.0.1","ips":["127.0.0.1","::1","172.20.0.21","fe80::acbc:9aff:fead:23e"],"now":"2017-08-11T01:47:45.690819416Z"}
$ curl nginx-svt-test-nfs.0810-5as.qe.rhcloud.com
{"version":"0.0.1","ips":["127.0.0.1","::1","172.20.3.22","fe80::858:acff:fe14:316"],"now":"2017-08-11T01:47:48.775137287Z"}
```
Verify shared volume:

```sh
# #create file on one pod
# oc exec web-0 -- touch /mydata/aaa.txt
# oc exec web-1 -- ls /mydata/
aaa.txt
```

