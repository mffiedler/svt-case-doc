# ETCD

## Doc

* [etcd on github](https://github.com/coreos/etcd)
* similar tools: [1]
* [installation](https://github.com/coreos/etcd/releases/)
* [etcdctl](https://github.com/coreos/etcd/tree/master/etcdctl)
* [official doc](https://github.com/coreos/etcd/blob/master/Documentation/docs.md)

## Commands

### Spike on etcd process

```sh
# netstat -atnp | grep etcd | grep LISTEN
tcp        0      0 127.0.0.1:2379          0.0.0.0:*               LISTEN      1624/etcd           
tcp        0      0 127.0.0.1:2380          0.0.0.0:*               LISTEN      1624/etcd           
# ps -ef | grep etcd                                                             
root       1624   1557  0 16:32 pts/1    00:00:02 /tmp/etcd-download-test/etcd
```

### [Interacting with ectd](https://github.com/coreos/etcd/blob/master/Documentation/dev-guide/interacting_v3.md)

#### [ectdctrl api version](https://github.com/coreos/etcd/blob/master/Documentation/dev-guide/interacting_v3.md)

```sh
# export ETCDCTL_API=3
```

#### Get all revisions of a key

```sh
# etcdctl watch <key> --rev=2
```

#### Get the current revision of a key

```sh
# etcdctl get <key> -w json
```

#### Get all k-v pairs

```sh
# etcdctl get "" --prefix=true
```

## etcd@oc

### Check etcd endpoints on master-config
On master:

```sh
# grep "etcdClientInfo" /etc/origin/master/master-config.yaml -A 5
etcdClientInfo:
  ca: master.etcd-ca.crt
  certFile: master.etcd-client.crt
  keyFile: master.etcd-client.key
  urls:
    - https://ip-172-31-58-73.us-west-2.compute.internal:2379
```

On etcd node:

```sh
# etcd --version
etcd Version: 3.1.9
Git SHA: 0f4a535
Go Version: go1.8.3
Go OS/Arch: linux/amd64

# ETCDCTL_API=3 etcdctl version
etcdctl version: 3.1.9
API version: 3.1

# systemctl status etcd.service
```

### Explore data

```sh
# ETCDCTL_API=3 etcdctl \
    --cacert="/etc/origin/master/master.etcd-ca.crt" \
    --cert="/etc/origin/master/master.etcd-client.crt" \
    --key="/etc/origin/master/master.etcd-client.key" \
    --endpoints=[172.31.58.73:2379] \
    --order="DESCEND" --sort-by="CREATE" --write-out="fields"
    get "" --prefix=true

# ETCDCTL_API=3 etcdctl \
    ...
    get --prefix "/kubernetes.io/pod"

# ETCDCTL_API=3 etcdctl get \
    ...
    --prefix "/kubernetes.io/persistentvolumes/pvc-eccab6ae-7615-11e7-9c34-0202902b5cf8" --rev=0
2017-07-31 13:56:54.368614 I | warning: ignoring ServerName for user-provided CA for backwards compatibility is deprecated
"ClusterID" : 14841639068965178418
"MemberID" : 10276657743932975437
"Revision" : 10392
"RaftTerm" : 2
"Key" : "/kubernetes.io/persistentvolumes/pvc-eccab6ae-7615-11e7-9c34-0202902b5cf8"
"CreateRevision" : 9588
"ModRevision" : 9589
"Version" : 2
"Value" : "k8s\x00\n\x16\n\x02v1\x12\x10PersistentVolume\x12\x84\x05\n\xb4\x03\n(pvc-eccab6ae-7615-11e7-9c34-0202902b5cf8\x12\x00\x1a\x00\"B/api/v1/persistentvolumes/pvc-eccab6ae-7615-11e7-9c34-0202902b5cf8*$ee28db00-7615-11e7-9c34-0202902b5cf82\x008\x00B\b\b\xae\xd2\xfd\xcb\x05\x10\x00Z5\n(failure-domain.beta.kubernetes.io/region\x12\tus-west-2Z4\n&failure-domain.beta.kubernetes.io/zone\x12\nus-west-2bb6\n\x17kubernetes.io/createdby\x12\x1baws-ebs-dynamic-provisionerb+\n$pv.kubernetes.io/bound-by-controller\x12\x03yesb8\n\x1fpv.kubernetes.io/provisioned-by\x12\x15kubernetes.io/aws-ebsz\x00\x12\xbd\x01\n\x10\n\astorage\x12\x05\n\x031Gi\x124\x122\n&aws://us-west-2b/vol-0974854f00804c76e\x12\x04ext4\x18\x00 \x00\x1a\rReadWriteOnce\"W\n\x15PersistentVolumeClaim\x12\x03aaa\x1a\apvc-ebs\"$eccab6ae-7615-11e7-9c34-0202902b5cf8*\x02v12\x049585:\x00*\x06Delete2\x03gp2\x1a\v\n\x05Bound\x12\x00\x1a\x00\x1a\x00\"\x00"
"Lease" : 0
"More" : false
"Count" : 1

```

## Reference

[1]. https://www.consul.io/intro/vs/zookeeper.html
