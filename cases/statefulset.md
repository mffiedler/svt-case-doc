# Test StatefulSets


## Calculation of stress

* #computing-node: 4, with limit 30 pods/node. So #pod=120
* #replica: 2 for each SS

So in total we can create 60 SS(s).

_Note_ that there is a [limited](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/volume_limits.html#linux-specific-volume-limits) number (40) of ebs-volumes attached to an ec2-instance.

### Vertical stress
1 project and many pods: #proj 1 and #template 60

### Horizontal stress
many project and 1 SS for each project: #proj 60 and #template 1

## Run

```sh
# cd svt/openshift_scalability/
# python -u cluster-loader.py -f config/pyconfigStatefulSet.yaml  -v
```

## Check

```sh
# #pods for each SS should be created in order (reverse order if delete)
# #120 pods should be in Running status
# watch -n 10 "oc get pods --all-namespaces"
# or watch by oc command
# oc get pods --all-namespaces -w
# #watch pvc
# #120 pvc(s) should be created, each for a pod
# oc get pvc --all-namespaces -w
# #each sever has 2 endpoints to proxy, and #server should be equal to #SS
# oc get endpoints --all-namespaces
NAMESPACE         NAME               ENDPOINTS                                                  AGE
clusterproject0   server0            172.20.0.13:8080,172.20.0.17:8080                          38m
# #you might want to watch events too
# oc get event --all-namespaces -w | grep -v Normal | grep -v FailedScheduling
...
```

## Clean projects
Change according to real number of created projects:

```sh
# for i in {0..2}; do oc delete project "clusterproject$i"; done
```
