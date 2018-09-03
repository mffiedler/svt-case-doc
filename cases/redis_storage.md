# Storage Test for Redis

## Use the template from OCP

```sh
# oc process --parameters -n openshift redis-persistent
NAME                    DESCRIPTION                                                   GENERATOR           VALUE
MEMORY_LIMIT            Maximum amount of memory the container can use.                                   512Mi
NAMESPACE               The OpenShift Namespace where the ImageStream resides.                            openshift
DATABASE_SERVICE_NAME   The name of the OpenShift Service exposed for the database.                       redis
REDIS_PASSWORD          Password for the Redis connection user.                       expression          [a-zA-Z0-9]{16}
VOLUME_CAPACITY         Volume space available for data, e.g. 512Mi, 2Gi.                                 1Gi
REDIS_VERSION           Version of Redis image to be used (3.2 or latest).                                3.2

# oc get template -n openshift redis-persistent -o yaml > redis-persistent-template-ttt.yaml
# vi redis-persistent-template-ttt.yaml
...
        storage: ${VOLUME_CAPACITY}
    storageClassName: ${STORAGE_CLASS_NAME}
...
- description: Storage Class Name of PVC.
  displayName: Storage Class Name
  name: STORAGE_CLASS_NAME
  required: true
  value: "gp2"

```

Or download the modified version:

```sh
# curl -O -L https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/redis-persistent-template-ttt.yaml
```

## Redis Persistence

[doc](https://redis.io/topics/persistence)

```sh
### redis pod: setting of persistence
### https://redis.io/commands/config-set
# oc rsh redis-1-ntvg8
sh-4.2$ redis-cli -a redhat
127.0.0.1:6379> CONFIG GET save
1) "save"
2) "900 1 300 10 60 10000"
127.0.0.1:6379> CONFIG GET appendonly
1) "appendonly"
2) "no"
```

## Benchmark tools

* ycsb
* [redis-pbenchmark](https://redis.io/topics/benchmarks): [tutorials](https://www.tutorialspoint.com/redis/redis_benchmarks.htm)