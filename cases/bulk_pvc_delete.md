# Bulk PVC Delete Test

## Test Env.
* 1 master, 1 infra, 1 compute: m4.xlarge
* 3 cns, 1 heketi: m4.4xlarge

## Pre-actions

Move pods to desired nodes and label the nodes as described [glusterFS_stress.md](glusterFS_stress.md).


## Run the test

Create PVCs with cluster-loader as described [here](glusterFS.md#run-test).

```sh
### Optional tuningsets
# vi svt/openshift_scalability/content/pvc-templates/pvc-parameters.yaml
tuningsets:
  - name: default
    templates:
      stepping:
        stepsize: 10
        pause: 1000 ms
      rate_limit:
        delay: 1000 ms
```

Wait until all PVC are BOUND and then delete PVC and measure the time:

```sh
$ wget https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/delete_pvc.sh
$ chmod +x delete_pvc.sh
$ ./delete_pvc.sh
```


## PVC delete test

### Results

#### oc (v3.7.0-0.143.7 + ol2 + sc)

glusterfs (3.3.0-12) and heketi (3.3.0-9)

| #PVC | 10  | 20 | 30 | 50 | 100 | 200 | 250 |
|------|-----|----|----|----|-----|-----|-----|
| #sec | 89  |  162  | 1476   |    |     |     |     |
| avg  | 8.9 |  8.1  |  29.5  |    |     |     |     |

gp2

| #PVC | 10  | 20 | 30 | 50 | 100 | 200 | 250 |
|------|-----|----|----|----|-----|-----|-----|
| #sec | 6  |  5  |  6  | 11   | 16    | 34    |     |
| avg  | 0.6 |  0.25  | 0.2   | 0.2   |  o.16   | 0.17    |     |

#### oc (v3.7.0-0.178.0 + ol2)

glusterfs (3.3.0-362) and heketi (3.3.0-362)

| #PVC | 10  | 20 | 30 | 50 | 100 | 200 | 250 |
|------|-----|----|----|----|-----|-----|-----|
| #sec | 84  |  163  | 262   |    |     |     |     |
| avg  | 8.4 |  8.2  |  8.7  |    |     |     |     |
