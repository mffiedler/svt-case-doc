# [pbench](https://github.com/distributed-system-analysis/pbench)

## Doc

* [pbench](http://distributed-system-analysis.github.io/pbench/) and [pbench-doc](http://distributed-system-analysis.github.io/pbench/doc/)
* [pbench-agent: user guide](http://distributed-system-analysis.github.io/pbench/pbench-agent.html)
* [pbench-fio](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-fio.md): [ipos wiki](https://en.wikipedia.org/wiki/IOPS), [ipos, throughput, and latency](http://searchsolidstatestorage.techtarget.com/definition/IOPS-Input-Output-Operations-Per-Second), [stddevpct](http://help.mastock.michelmontagne.com/Indicateurs/CustomIndicators/keywordshelp/customIndicsstdDevPct/index.html), and [lat, clat, slat](https://linux.die.net/man/1/fio)
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
Linux 3.10.0-774.el7.x86_64 (ip-172-31-24-121.us-west-2.compute.internal) 	12/01/17 	_x86_64_	(4 CPU)

12/01/17 17:30:16
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          14.45    0.00    2.85    0.69    0.13   81.89

Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
xvda              0.00     0.10   47.40   54.20     3.13     0.32    69.38     0.14    1.41    0.96    1.80   0.50   5.05
xvdb              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00
```

pbench uses iostat with <code>-x</code>, ie, extended statistics as the output. The values shows in the stats graphs are:

* IOPS: <code>r/s</code> and <code>w/s</code>
* Throughput_MB_per_sec: <code>rMB/s</code> and <code>wMB/s</code>

Understand the output: [1](https://coderwall.com/p/utc42q/understanding-iostat), [2](http://www.thegeekstuff.com/2011/07/iostat-vmstat-mpstat-examples/?utm_source=feedburner), [3](https://coderwall.com/p/utc42q/understanding-iostat).

* avgrq-sz: The average size (in sectors) of the requests that were issued to the device. [How to find the
sector size](https://unix.stackexchange.com/questions/2668/finding-the-sector-size-of-a-partition):

```sh
$ sudo fdisk -l
Disk /dev/xvda: 30 GiB, 32212254720 bytes, 62914560 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xc006e828

Device     Boot Start      End  Sectors Size Id Type
/dev/xvda1 *     2048 62914559 62912512  30G 83 Linux
```

So "Request_Size_in_512_byte_sectors" is one of titles of pbench graphs.


### [pprof](https://github.com/google/pprof)

## Run pbench for one node only

After ssh to that node:

```sh
# vi ~/svt/openshift_scalability/pbench-register.sh
pbench-register-tool --name=pprof -- --osecomponent=node
```

Note that the value of <code>--osecomponent</code> is either _master_ or _node_, up to the role
of the node where we want to run pbench.


## [pbench-fio](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-fio.md)

A wrapper application of [fio.md](fio.md). [parameters](https://github.com/axboe/fio/blob/master/HOWTO) in fio job configuration:

* bs: The block size in bytes used for I/O units
* size: The total size of file I/O for each thread of this job.
* runtime: Tell fio to terminate processing after the specified period of time.
* ramp_time: If set, fio will run the specified workload for this amount of time before logging any performance numbers.
* startdelay: Delay the start of job for the specified amount of time.
* sync: Use synchronous I/O for buffered writes. For the majority of I/O engines, this means using O_SYNC.
* iodepth: Number of I/O units to keep in flight against the file.
* direct: used but not example in [fio HOWTO page](https://github.com/axboe/fio/blob/master/HOWTO), neither in [fio man page](https://linux.die.net/man/1/fio).
* sync vs direct: [here](https://stackoverflow.com/questions/5055859/how-are-the-o-sync-and-o-direct-flags-in-open2-different-alike)

### Understand pbench-fio data

#### Thoughput
How many units of information a system can process in a period of time.

* Throughput: Size of units that IO operations process per second, eg, 160 MiB/s.
* IOPS: Input/output operations per second, eg, 10,000.
* IO size or block size: the unit each IO operation processes, eg, 16 KiB.

So here the formula is <code>Throughput = block size * IOPS</code>. See stat of [ebs volume types](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html).

#### [latency](http://searchstorage.techtarget.com/definition/IOPS-input-output-operations-per-second)
A measure of the length of time it takes for a single I/O request to be completed from the application's point of view. The tool fio measures 3 kinds of latency:

* lat: Total latency. Same names as slat and clat, this denotes the time from when fio created the I/O unit to completion of the I/O operation.
* clat: Completion latency. It denotes the time from submission to completion of the I/O pieces.
* slat: Submission latency. This is the time it took to submit the I/O.

Server and client data on pbench-fio:

* server throughput: sum of all clients' throughput
* server latency: average of all clients' latency
