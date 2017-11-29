# Storage Test
This test is to run (via ssh) fio command in a CentOS pod on pbench remote node and send pbench-results to pbench server. 

## Doc
* [src](https://github.com/openshift/svt/tree/master/storage)
* [Siva's Demo](https://bluejeans.com/playback/s/BxX2fG6y4ZjAaii8JH1o7on8NfcZj2PV530lLKvyXyjPf3I5oOKQkizb939slYdT)
* [pbench-fio](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-fio.md)
* [fio](../learn/fio.md)

## About the test

* The bash script <code>start-storage-test.sh</code> collects nodes in <code>config.yaml</code> and starts <code>storage-test.py</code>
* The python script <code>storage-test.py</code> sets up variables and starts the playbook <code>fio-test-setup.yaml</code>.
* <code>fio-test-setup.yaml</code>

  * Build a special docker image based on Dockerfile <code>fio/Dockerfile</code>
  * Create pod based on the above image
  * Run <code>pbench-fio</code> using the pod as client

See [storage_manual_steps.md](storage_manual_steps.md) for more details.

## EBS

### Run

```sh
# vi /etc/origin/master/master-config.yaml
...
projectConfig:
  defaultNodeSelector: ""
...

# systemctl restart atomic-openshift-master

# svt/storage
# #change the hosts in the cluster
# #nodes are compute nodes
# vi config.yaml
# scp id_rsa.pub to svt/storage/id_rsa.pub

# ./start-storage-test.sh
# OR,
# python storage-test.py fio --master ip-172-31-34-193.us-west-2.compute.internal --node ip-172-31-38-167.us-west-2.compute.internal
```

where _ip-172-31-34-193.us-west-2.compute.internal_ is the master node and _ip-172-31-38-167.us-west-2.compute.internal_ is the compute node where we want to run the pod on.

### Debug
Every test should run for a bout 2 - 3 mins.

```sh
# ll /var/lib/pbench-agent/fio_SEQ_IO_2017.08.29T13.11.11/
total 4
drwxr-xr-x. 5 root root  107 Aug 29 09:15 1-read-4KiB
drwxr-xr-x. 5 root root  107 Aug 29 09:17 2-read-128KiB
drwxr-xr-x. 5 root root  107 Aug 29 09:20 3-read-4096KiB
drwxr-xr-x. 5 root root  107 Aug 29 09:23 4-write-4KiB
drwxr-xr-x. 5 root root  107 Aug 29 09:25 5-write-128KiB
drwxr-xr-x. 5 root root  107 Aug 29 09:28 6-write-4096KiB
drwxr-xr-x. 3 root root   58 Aug 29 10:54 7-rw-4KiB
drwxr-xr-x. 3 root root   21 Aug 29 11:11 8-rw-128KiB
-rw-r--r--. 1 root root 1791 Aug 29 11:11 metadata.log
drwxr-xr-x. 3 root root   17 Aug 29 09:12 sysinfo
drwxr-xr-x. 2 root root    6 Aug 29 09:12 tmp

```

TODO: For the momemnt (OS 3.6), it takes much longer starting from <code>7-rw-4KiB</code>. It could be caused by pbench or the attached ebs-device.


Run <code>iostat</code> on the compute node,

```sh
# #on master
# oc get pvc -n fio-1 -o yaml | grep volumeName
    volumeName: pvc-6e737047-8cbb-11e7-9524-02389db2b36e
root@ip-172-31-34-193: ~/svt/storage # oc get pv pvc-6e737047-8cbb-11e7-9524-02389db2b36e -o yaml | grep volumeID
    volumeID: aws://us-west-2b/vol-0aaebf62041a345a1

# #on the computing node
# df -h | grep vol-0aaebf62041a345a1
/dev/xvdbq      9.8G  1.1G  8.2G  12% /var/lib/origin/openshift.local.volumes/plugins/kubernetes.io/aws-ebs/mounts/aws/us-west-2b/vol-0aaebf62041a345a1

# iostat -t 10 /dev/xvdbq
Linux 3.10.0-693.el7.x86_64 (ip-172-31-38-167.us-west-2.compute.internal) 	08/29/2017 	_x86_64_	(4 CPU)

08/29/2017 11:38:30 AM
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.31    0.00    1.78    2.05    0.09   94.77

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
xvdbq            35.33      1443.25      3036.10   17830020   37508081

```

Or run it inside the container

```sh
# oc get pod -n fio-1 
NAME          READY     STATUS    RESTARTS   AGE
fio-1-c8p83   1/1       Running   0          2h

# oc volumes pod fio-1-c8p83 -n fio-1 
pods/fio-1-c8p83
  pvc/fio (allocated 10GiB) as fio-data
    mounted at /var/lib/fio

# oc rsh fio-1-c8p83
sh-4.2# df -h | grep fio
/dev/xvdbq                                                                                         9.8G  1.1G  8.2G  12% /var/lib/fio

sh-4.2# iostat -t 10  /dev/xvdbq  
Linux 3.10.0-693.el7.x86_64 (fio-1-c8p83) 	08/29/17 	_x86_64_	(4 CPU)

08/29/17 15:43:40
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.29    0.00    1.74    2.00    0.08   94.88

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
xvdbq            34.46      1407.97      2961.87   17830020   37508081
```


### Check pbench results
check pbench results: [example](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-24-235/). Compare to Siva's [results for OS 3.5](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-14-88/).


### Manual clean-up
If some error happens, we want to rerun the test:

```sh
# oc delete project fio-1
# oc delete scc fio
# #might also need to kill pbench processes manually including pbench remote nodes
# ps -ef | grep fio | grep pbench | awk '{print $2}' | xargs kill -9
```

## GlusterFS

### Modify pod template
Moidy <code>content/fio-pod-pv.json</code> to use the storage class which represents glusterFS. _Note_ that it is not supported for the moment to run 2 fio tests with the same gluster.

### iostat

<code>iostat</code> command is trickier for glusterFS: It is not easy to tell which volume/device is the target.
This workaround might or might not he helpful:

On master: 10 pv as expected:

```sh
# oc get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM       STORAGECLASS        REASON    AGE
pvc-e9cbba07-8ceb-11e7-9524-02389db2b36e   10Gi       RWO           Delete          Bound     fio-1/fio   glusterfs-storage             54m

```

On the compute node:

```sh
# dmsetup ls | grep brick
vg_1ac8a03843d4533d13c75f98649fe2c1-brick_1b68251da2a4c23afada88be77027317	(253:14)
vg_1ac8a03843d4533d13c75f98649fe2c1-brick_b625216d682febee41dbdafab4e9b4bd	(253:11)
```
This tells us that target is either 14 or 11.

```sh
# lsblk | grep brick
│   └─vg_1ac8a03843d4533d13c75f98649fe2c1-brick_1b68251da2a4c23afada88be77027317              253:14   0  10G  0 lvm  
│   └─vg_1ac8a03843d4533d13c75f98649fe2c1-brick_1b68251da2a4c23afada88be77027317              253:14   0  10G  0 lvm  
│   └─vg_1ac8a03843d4533d13c75f98649fe2c1-brick_b625216d682febee41dbdafab4e9b4bd              253:11   0   2G  0 lvm  
    └─vg_1ac8a03843d4533d13c75f98649fe2c1-brick_b625216d682febee41dbdafab4e9b4bd              253:11   0   2G  0 lvm 
```

Then we know that our volume is 10g, so number 14 is our target:

```sh
# iostat -t 10 dm-14
Linux 3.10.0-693.el7.x86_64 (ip-172-31-46-56.us-west-2.compute.internal) 	08/29/2017 	_x86_64_	(4 CPU)

08/29/2017 03:54:55 PM
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.00    0.00    1.22    1.55    0.09   96.15

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
dm-14             4.92         0.17       792.94       4647   21995043

```

## pbench results

[example](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-34-193/)


pbench data collection:

In case of glusterfs, 3 dedicated m2.4xlarge nodes for glusterfs and 1 m2.4xlarge node for heketi.

| date     | oc version                      | pbench version  | storage   | other info                               | link                                                                                                                                                                    |
|----------|---------------------------------|-----------------|-----------|------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 20170222 | 3.5                             | na              | ebs       |                                          | [server](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-14-88/) and [ex-server](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-14-88/)   |
| 20171005 | 3.7.0-0.126.4.git.0.3fc2b9b.el7 | 0.45-1g8874a17  | ebs       |                                          | [server](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-53-207/) and [ex-server](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-53-207/) |
| 20171016 | 3.7.0-0.153.0.git.0.88d9b46.el7 | 0.46-53g6327ec7 | glusterfs | glusterfs=3.2.0-7 <br /> heketi=3.2.0-11 | [server](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-11-69/) and [ex-server](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-11-69/)   |
| 20171122 | 3.7.9-1.git.0.7c71a2d.el7       | 0.46-78g30019c5 | ebs       |                                          | [server](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-62-216/) and [ex-server](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-62-216/) |
| 20171122 | 3.7.9-1.git.0.7c71a2d.el7       | 0.46-78g30019c5 | glusterfs |  glusterfs=3.3.0-362 <br /> heketi=3.3.0-362 <br /> block-p=3.3.0-362 | [server](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-11-189/) and [ex-server](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-11-189/) |
| 20171124 (15,16) | 3.7.9-1.git.0.7c71a2d.el7       | 0.46-78g30019c5 | glusterfs |  glusterfs=3.3.0-362 <br /> heketi=3.3.0-362 <br /> block-p=n/a | [server](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-41-184/) and [ex-server](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-41-184/) |
| 20171124 (18,19) | 3.7.9-1.git.0.7c71a2d.el7       | 0.46-78g30019c5 | glusterfs |  glusterfs=3.3.0-362 <br /> heketi=3.3.0-362 <br /> block-p=3.3.0-362 | [server](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-41-184/) and [ex-server](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-41-184/) |


## pbench-fio parm tuning

oc: 3.7.9-1.git.0.7c71a2d.el7, pbench: 0.46-78g30019c5, glusterfs: 3.3.0-362

Cluster for gp2: 1 master, 1 infra, 1 compute: m4.xlarge

Cluster for glusterfs: 1 master, 1 infra: m4.xlarge; 5 compute: m4.4xlarge


| round | sc        | params                                | pbench data                                                         |
|-------|-----------|---------------------------------------|---------------------------------------------------------------------|
| a1    | gp2       | sample=1, runtime=3600                |                                                                     |
| a2    | gp2       | sample=1, runtime=3600, ramp_time=300 |                                                                     |
| a3    | gp2       | sample=1, runtime=3600, ramp_time=300 |                                                                     |
| b1    | glusterfs | sample=1, runtime=3600                | [ip-172-31-26-171](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-26-171/) |
| b2    | glusterfs | sample=1, runtime=3600, ramp_time=300 | [ip-172-31-21-228](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-21-228/) |
| b3    | glusterfs | sample=1, runtime=3600, ramp_time=300 |                                                                     |
