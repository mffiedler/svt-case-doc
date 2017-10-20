# Tuned Profiles Verification

## [Tuned](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/performance_tuning_guide/index#chap-Red_Hat_Enterprise_Linux-Performance_Tuning_Guide-Tuned)

A tool that tunes system setting.

```sh
### Show tuned conf files
# ls -Rl /etc/tuned/
/etc/tuned/:
total 16
-rw-r--r--. 1 root root   24 Oct 19 17:56 active_profile
-rw-r--r--. 1 root root 1111 Jul 28 01:58 bootcmdline
drwxr-xr-x. 2 root root   24 Oct 19 17:56 openshift
drwxr-xr-x. 2 root root   24 Oct 19 17:56 openshift-control-plane
drwxr-xr-x. 2 root root   24 Oct 19 17:56 openshift-node
-rw-r--r--. 1 root root  268 Oct 19 17:56 recommend.conf
-rw-r--r--. 1 root root 1154 Jul 28 01:58 tuned-main.conf

/etc/tuned/openshift:
total 4
-rw-r--r--. 1 root root 570 Oct 19 17:56 tuned.conf

/etc/tuned/openshift-control-plane:
total 4
-rw-r--r--. 1 root root 744 Oct 19 17:56 tuned.conf

/etc/tuned/openshift-node:
total 4
-rw-r--r--. 1 root root 135 Oct 19 17:56 tuned.conf

### View the currently activated profile
### on master:
# tuned-adm active
Current active profile: openshift-control-plane
```

Check the conf:

```sh
### view content of the active profile
# cat /etc/tuned/openshift-control-plane/tuned.conf
#
# tuned configuration
#

[main]
summary=Optimize systems running OpenShift control plane
include=openshift

[sysctl]
# ktune sysctl settings, maximizing i/o throughput
#
# Minimal preemption granularity for CPU-bound tasks:
# (default: 1 msec#  (1 + ilog(ncpus)), units: nanoseconds)
kernel.sched_min_granularity_ns=10000000

# The total time the scheduler will consider a migrated process
# "cache hot" and thus less likely to be re-migrated
# (system default is 500000, i.e. 0.5 ms)
kernel.sched_migration_cost_ns=5000000

# SCHED_OTHER wake-up granularity.
#
# Preemption granularity when tasks wake up.  Lower the value to improve
# wake-up latency and throughput for latency critical tasks.
kernel.sched_wakeup_granularity_ns = 4000000
```

It includes another conf file:

```
# cat /etc/tuned/openshift/tuned.conf
#
# tuned configuration
#

[main]
summary=Optimize systems running OpenShift (parent profile)
include=${f:virt_check:atomic-guest:throughput-performance}

[selinux]
avc_cache_threshold=65536

[net]
nf_conntrack_hashsize=131072

[sysctl]
kernel.pid_max=131072
net.netfilter.nf_conntrack_max=1048576
fs.inotify.max_user_watches=65536
net.ipv4.neigh.default.gc_thresh1=8192
net.ipv4.neigh.default.gc_thresh2=32768
net.ipv4.neigh.default.gc_thresh3=65536
net.ipv6.neigh.default.gc_thresh1=8192
net.ipv6.neigh.default.gc_thresh2=32768
net.ipv6.neigh.default.gc_thresh3=65536
```

Check system parameters:

```sh
# sysctl -a | grep "kernel.pid_max"
kernel.pid_max = 131072
```

## Run the test


```sh
###===========master================
root@ip-172-31-57-114: ~ # atomic containers list --no-trunc
   CONTAINER ID                        IMAGE                                                            COMMAND                                    CREATED          STATE      BACKEND    RUNTIME
   etcd                                registry.access.redhat.com/rhel7/etcd                            /usr/bin/etcd-env.sh /usr/bin/etcd         2017-10-19 17:51 running    ostree     runc
   atomic-openshift-master-api         registry.ops.openshift.com/openshift3/ose:v3.7.0-0.158.0         /usr/local/bin/system-container-wrapper.sh 2017-10-19 17:56 running    ostree     runc
   atomic-openshift-master-controllers registry.ops.openshift.com/openshift3/ose:v3.7.0-0.158.0         /usr/local/bin/system-container-wrapper.sh 2017-10-19 17:56 running    ostree     runc
   atomic-openshift-node               registry.ops.openshift.com/openshift3/node:v3.7.0-0.158.0        /usr/local/bin/system-container-wrapper.sh 2017-10-19 17:59 running    ostree     runc
   openvswitch                         registry.ops.openshift.com/openshift3/openvswitch:v3.7.0-0.158.0 /usr/local/bin/system-container-wrapper.sh 2017-10-19 17:59 running    ostree     runc


root@ip-172-31-57-114: ~ # cat /etc/tuned/recommend.conf
[openshift-control-plane,master]
/etc/origin/master/master-config.yaml=.*

[openshift-control-plane,node]
/etc/origin/node/node-config.yaml=.*region=infra

[openshift-control-plane,lb]
/etc/haproxy/haproxy.cfg=.*

[openshift-node]
/etc/origin/node/node-config.yaml=.*
root@ip-172-31-57-114: ~ # tuned-adm active
Current active profile: openshift-control-plane

root@ip-172-31-57-114: ~ # sysctl -a | grep "net.ipv4.tcp_fastopen"
net.ipv4.tcp_fastopen = 0


###===========infra================
root@ip-172-31-48-92: ~ # tuned-adm active
Current active profile: openshift-control-plane

###===========node================
/etc/origin/node/node-config.yaml=.*
root@ip-172-31-32-238: ~ # tuned-adm active
Current active profile: openshift-node

root@ip-172-31-32-238: ~ # sysctl -a | grep "net.ipv4.tcp_fastopen"
sysctl: reading key "net.ipv6.conf.all.stable_secret"
net.ipv4.tcp_fastopen = 3
```
