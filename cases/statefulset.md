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
