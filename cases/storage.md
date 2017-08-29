# Storage Test
This test is to run (via ssh) fio command in a CentOS pod on pbench remote node and send pbench-results to pbench server. 

## Doc
* [src](https://github.com/openshift/svt/tree/master/storage)
* [Siva's Demo](https://bluejeans.com/playback/s/BxX2fG6y4ZjAaii8JH1o7on8NfcZj2PV530lLKvyXyjPf3I5oOKQkizb939slYdT)
* [pbench-fio](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-fio.md)

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

### 
