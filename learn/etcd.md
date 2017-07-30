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
# ./etcdctl watch <key> --rev=2
```

## Reference

[1]. https://www.consul.io/intro/vs/zookeeper.html
