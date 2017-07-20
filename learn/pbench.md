# [pbench](https://github.com/distributed-system-analysis/pbench)

## Installation
TODO (see AMI provisioning)

## Use pbench in the test

### Get nodes list

```sh
# oc get nodes
NAME                                          STATUS                        AGE       VERSION
ip-172-31-3-240.us-west-2.compute.internal    NotReady                      51m       v1.6.1+5115d708d7
ip-172-31-38-21.us-west-2.compute.internal    NotReady                      51m       v1.6.1+5115d708d7
ip-172-31-42-144.us-west-2.compute.internal   NotReady,SchedulingDisabled   58m       v1.6.1+5115d708d7
ip-172-31-60-244.us-west-2.compute.internal   NotReady                      50m       v1.6.1+5115d708d7
```

### Register
If run on master, register.sh will include itself automatically. So just list nodes other than master.

```sh
# svt/openshift_scalability/pbench-register.sh ip-172-31-3-240.us-west-2.compute.internal \
    ip-172-31-38-21.us-west-2.compute.internal \
    ip-172-31-60-244.us-west-2.compute.internal
```

### Start

```sh
# pbench-start-tools --dir=/var/lib/pbench-agent/hk-conc-scale-a
```

### Run test

### Stop, post-process, and copy

```sh
# pbench-stop-tools --dir=/var/lib/pbench-agent/hk-conc-scale-a
# pbench-postprocess-tools --dir=/var/lib/pbench-agent/hk-conc-scale-a
# pbench-copy-results
```

### Check if the results are uploaded

The results should show up in 10-15 mins on the [server](http://pbench.perf.lab.eng.bos.redhat.com/results/).
Important stats: sar (cpu & mem) and iostat folder.

