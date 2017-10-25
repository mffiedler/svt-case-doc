# Bulk PVC Delete Test

## Test Env.
1 master, 1 infra, 1 compute: m4.4xlarge
3 cns, 1 heketi: m4.xlarge

## Pre-actions

Move pods to desired nodes and label the nodes as described [glusterFS_stress.md](glusterFS_stress.md).


## Run the test

Create PVCs with cluster-loader as described [here](glusterFS.md#run-test).

Wait until all PVC are BOUND and then delete PVC and measure the time:

```sh
$ wget 
$ ./delete_pvc.sh
```


## PVC delete test

### Results

#### oc (v3.7.0-0.143.7 + ol2 + sc)

glusterfs (3.3.0-12) and heketi (3.3.0-9)

| #PVC | 10  | 20 | 30 | 50 | 100 | 200 | 250 |
|------|-----|----|----|----|-----|-----|-----|
| #sec | 89  |    |    |    |     |     |     |
| avg  | 8.9 |    |    |    |     |     |     |

gp2

| #PVC | 10  | 20 | 30 | 50 | 100 | 200 | 250 |
|------|-----|----|----|----|-----|-----|-----|
| #sec | 6  |  5  |  6  | 11   | 16    | 34    |     |
| avg  | 0.6 |  0.25  | 0.2   | 0.2   |  o.16   | 0.17    |     |



