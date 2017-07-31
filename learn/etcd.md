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
```

## Reference

[1]. https://www.consul.io/intro/vs/zookeeper.html
