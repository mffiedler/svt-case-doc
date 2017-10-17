# [pbench](https://github.com/distributed-system-analysis/pbench)

## Doc

* [pbench](http://distributed-system-analysis.github.io/pbench/) and [pbench-doc](http://distributed-system-analysis.github.io/pbench/doc/)
* [pbench-agent: user guide](http://distributed-system-analysis.github.io/pbench/pbench-agent.html)
* [pbench-fio](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-fio.md), [ipos wiki](https://en.wikipedia.org/wiki/IOPS), [ipos, throughput, and latency](http://searchsolidstatestorage.techtarget.com/definition/IOPS-Input-Output-Operations-Per-Second), [stddevpct](http://help.mastock.michelmontagne.com/Indicateurs/CustomIndicators/keywordshelp/customIndicsstdDevPct/index.html)
* [pbench-uperf](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-uperf.md)

## Installation

### [Server](http://distributed-system-analysis.github.io/pbench/doc/server/installation.html)
### [Client](http://distributed-system-analysis.github.io/pbench/doc/agent/installation.html)

```sh
# #install pbench-agent
$ wget https://copr.fedorainfracloud.org/coprs/ndokos/pbench/repo/fedora-26/ndokos-pbench-fedora-26.repo
$ sudo mv ndokos-pbench-fedora-26.repo /etc/yum.repos.d/
```

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

### [iostat](https://linux.die.net/man/1/iostat)

[command examples](http://www.thegeekstuff.com/2011/07/iostat-vmstat-mpstat-examples/)

```sh
# iostat  -N -t -y -x -m 10
```


### [pprof](https://github.com/google/pprof)

### [fio](https://linux.die.net/man/1/fio)

[fio.md](fio.md)

## Run pbench for one node only

After ssh to that node:

```sh
# vi ~/svt/openshift_scalability/pbench-register.sh
pbench-register-tool --name=pprof -- --osecomponent=node
```

Note that the value of <code>--osecomponent</code> is either _master_ or _node_, up to the role
of the node where we want to run pbench.
