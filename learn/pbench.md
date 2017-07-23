# [pbench](https://github.com/distributed-system-analysis/pbench)

## Installation
TODO (see AMI provisioning)

## Use pbench in the test

### Get nodes list

```sh
# oc get nodes
NAME                                          STATUS                     AGE       VERSION
ip-172-31-19-228.us-west-2.compute.internal   Ready                      9m        v1.6.1+5115d708d7
ip-172-31-20-24.us-west-2.compute.internal    Ready                      9m        v1.6.1+5115d708d7
ip-172-31-45-92.us-west-2.compute.internal    Ready                      9m        v1.6.1+5115d708d7
ip-172-31-58-220.us-west-2.compute.internal   Ready,SchedulingDisabled   9m        v1.6.1+5115d708d7
```

### Register
If run on master, register.sh will include itself automatically. So just list nodes other than master.

```sh
# svt/openshift_scalability/pbench-register.sh ip-172-31-19-228.us-west-2.compute.internal \
    ip-172-31-20-24.us-west-2.compute.internal \
    ip-172-31-45-92.us-west-2.compute.internal
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

### Clean up before Rerun
To run pbench again, no need to register the tools again, but you should run <code>pbench-clear-results</code> on _EVERY_ node.

## Read the stats from pbench

Example of pbench stats is [here](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-58-220/).

### [sar](https://linux.die.net/man/1/sar)

CPU, Memory, Network, ...

[command examples](https://www.ibm.com/support/knowledgecenter/en/ssw_aix_61/com.ibm.aix.cmds5/sar.htm)

```sh
# sar -A 10
```

### [pidstat](https://linux.die.net/man/1/pidstat)

[command examples](http://www.thegeekstuff.com/2014/11/pidstat-examples/)

```sh
# pidstat  -l -w -u -h -d -r  -p ALL  10
```

### [pprof](https://github.com/google/pprof)
