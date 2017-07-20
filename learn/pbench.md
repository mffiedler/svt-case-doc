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
svt/openshift_scalability/pbench-register.sh ip-172-31-3-240.us-west-2.compute.internal ip-172-31-38-21.us-west-2.compute.internal
```

72 svt/openshift_scalability/pbench-register.sh ip-172-31-27-130.us-west-2.compute.internal ip-172-31-37-105.us-west-2.compute.internal ip-172-31-60-181.us-west-2.compute.internal
73 pbench-start-tools --dir=/var/lib/pbench-agent/hk-conc-scale-a
### run the test (we do it by Jenkins)
   74 pbench-stop-tools --dir=/var/lib/pbench-agent/hk-conc-scale-a
  75 pbench-postprocess-tools --dir=/var/lib/pbench-agent/hk-conc-scale-a
  76 pbench-copy-results
### the result should show up in 10-15 mins
http://pbench.perf.lab.eng.bos.redhat.com/results/
Important stats: sar (cpu & mem) and iostat folder

