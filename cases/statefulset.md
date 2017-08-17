# Test StatefulSets


## Calculation of stress

* #computing-node: 4, with limit 30 pods/pod. So #pod=120
* #replica: 2 for each SS

So in total we can create 60 SS(s).

### Vertical stress
1 project and many pods: #proj 1 and #template 60

### Vertical stress
many project and 1 SS for each project: #proj 60 and #template 1

## Run

```sh
# cd svt/openshift_scalability/
# python -u cluster-loader.py -f config/pyconfigStatefulSet.yaml  -v
```

## Check

```sh
# #pods for each SS should created in order (reverse order if delete)
# watch -n 10 "oc get pods --all-namespaces"
# or watch by oc command
# oc get pods --all-namespaces -w
# #each sever has 2 endpoints to proxy, and #server should be equal to #SS
# oc get endpoints --all-namespaces
NAMESPACE         NAME               ENDPOINTS                                                  AGE
clusterproject0   server0            172.20.0.13:8080,172.20.0.17:8080                          38m
...
```

