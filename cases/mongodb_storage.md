# Storage Test for MongoDB

## Use template from openshift

Modify the template `-n openshift mongodb-persistent` with storage class name as a variable:

```sh
# oc get template -n openshift mongodb-persistent -o yaml > mongodb-persistent-template-ttt.yaml
# vi mongodb-persistent-template-ttt.yaml
...
        storage: ${VOLUME_CAPACITY}
    storageClassName: ${STORAGE_CLASS_NAME}
...
- description: Storage Class Name of PVC.
  displayName: Storage Class Name
  name: STORAGE_CLASS_NAME
  required: true
  value: "gp2"

# oc process --parameters -f ./mongodb-persistent-template-ttt.yaml
NAME                     DESCRIPTION                                                               GENERATOR           VALUE
MEMORY_LIMIT             Maximum amount of memory the container can use.                                               512Mi
NAMESPACE                The OpenShift Namespace where the ImageStream resides.                                        openshift
DATABASE_SERVICE_NAME    The name of the OpenShift Service exposed for the database.                                   mongodb
MONGODB_USER             Username for MongoDB user that will be used for accessing the database.   expression          user[A-Z0-9]{3}
MONGODB_PASSWORD         Password for the MongoDB connection user.                                 expression          [a-zA-Z0-9]{16}
MONGODB_DATABASE         Name of the MongoDB database accessed.                                                        sampledb
MONGODB_ADMIN_PASSWORD   Password for the database admin user.                                     expression          [a-zA-Z0-9]{16}
VOLUME_CAPACITY          Volume space available for data, e.g. 512Mi, 2Gi.                                             1Gi
MONGODB_VERSION          Version of MongoDB image to be used (2.4, 2.6, 3.2 or latest).                                3.2
STORAGE_CLASS_NAME       Storage Class Name of PVC.                                                                    gp2

```

Or download the modified version:

```sh
# curl -O -L https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/mongodb-persistent-template-ttt.yaml
```


Deploy `mongodb` with the template:

```sh
# oc new-project ttt
### glusterfs-storage-block
# oc process -f ./mongodb-persistent-template-ttt.yaml -p MEMORY_LIMIT=4096Mi -p MONGODB_USER=redhat -p MONGODB_PASSWORD=redhat -p MONGODB_DATABASE=testdb -p VOLUME_CAPACITY=100Gi -p STORAGE_CLASS_NAME=glusterfs-storage-block | oc create -f -

### glusterfs-storage
# oc process -f ./mongodb-persistent-template-ttt.yaml -p MEMORY_LIMIT=4096Mi -p MONGODB_USER=redhat -p MONGODB_PASSWORD=redhat -p MONGODB_DATABASE=testdb -p VOLUME_CAPACITY=100Gi -p STORAGE_CLASS_NAME=glusterfs-storage | oc create -f -

### pg2
# oc process -f ./mongodb-persistent-template-ttt.yaml -p MEMORY_LIMIT=4096Mi -p MONGODB_USER=redhat -p MONGODB_PASSWORD=redhat -p MONGODB_DATABASE=testdb -p VOLUME_CAPACITY=1000Gi -p STORAGE_CLASS_NAME=gp2 | oc create -f -

# oc get all
NAME                        REVISION   DESIRED   CURRENT   TRIGGERED BY
deploymentconfigs/mongodb   1          1         1         config,image(mongodb:3.2)

NAME                 READY     STATUS    RESTARTS   AGE
po/mongodb-1-wlsr7   1/1       Running   0          1m

NAME           DESIRED   CURRENT   READY     AGE
rc/mongodb-1   1         1         1         1m

NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
svc/mongodb   ClusterIP   172.25.112.44   <none>        27017/TCP   1m

# oc get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS              AGE
mongodb   Bound     pvc-c1e04e9b-2ea0-11e8-bc3e-02b5874ae424   10Gi       RWO            glusterfs-storage-block   1m

# oc get pod -o yaml | grep "image:" | sort -u
      image: registry.access.redhat.com/rhscl/mongodb-32-rhel7@sha256:82c79f0e54d5a23f96671373510159e4fac478e2aeef4181e61f25ac38c1ae1f

### Checking if user/passwd works
# oc rsh mongodb-1-wlsr7
sh-4.2$ mongo -u redhat -p redhat 127.0.0.1:27017/testdb
MongoDB shell version: 3.2.10
connecting to: 127.0.0.1:27017/testdb
> db.student.insert({"name": "bbb"})
WriteResult({ "nInserted" : 1 })
> db.student.count()
1
> db.student.remove({})
WriteResult({ "nRemoved" : 1 })
> db.student.count()
0
> exit
bye


###
#
```

Move the pod to a node with label `aaa=bbb`
```sh
# oc patch -n ttt deploymentconfigs/mongodb --patch '{"spec": {"template": {"spec": {"nodeSelector": {"aaa": "bbb"}}}}}'
```

## Benchmark: [YCSB](https://github.com/brianfrankcooper/YCSB)

```sh
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/dc_ycsb.yaml
```

Move the pod to a node with label `aaa=bbb`
```sh
# oc patch -n ttt deploymentconfigs/ycsb --patch '{"spec": {"template": {"spec": {"nodeSelector": {"aaa": "bbb"}}}}}'
```

```sh
# oc exec $(oc get pod -n ttt | grep ycsb | awk '{print $1}') -- ./bin/ycsb load mongodb -s -P workloads/workloadt/workloadt -p mongodb.url=mongodb://redhat:redhat@172.24.183.75:27017/testdb
```

```sh
### Inside mongo pod
$ mongo -u redhat -p redhat 127.0.0.1:27017/testdb --eval "db.usertable.remove({})"
```


Need to clean the test data generated by `ycsb`.

Clean:
```sh
### ref https://bugzilla.redhat.com/show_bug.cgi?id=1560559
# oc exec mongodb-2-4v2mb -- scl enable rh-mongodb32 -- mongo -u redhat -p redhat 172.24.183.75:27017/testdb --eval "db.u
```

## Run test by script

Standalone:

```sh
# curl -O -L https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/test-mongo.sh
# bash test-mongo.sh >> file$(date '+%Y-%m-%d-%H-%M-%S').txt 2>&1
# grep Throughput $(ls -t | head -n 1) | awk '{ total += $3 } END { print total/10 }'
```

as input script for pbench-user-benchmark:

```sh
# pbench-user-benchmark --config="mongo_storage_test" -- bash test-mongo.sh
### Or,

# curl -O -L https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/test-mongo-with-pbench.sh
# bash ./test-mongo-with-pbench.sh
```
