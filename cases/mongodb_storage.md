# Storage Test for MongoDB

## Use template

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

Deploy `mongodb` with the template:

```sh
# oc new-project ttt
# oc process -f ./mongodb-persistent-template-ttt.yaml -p MEMORY_LIMIT=1024Mi -p MONGODB_USER=redhat -p MONGODB_PASSWORD=redhat -p MONGODB_DATABASE=testdb -p VOLUME_CAPACITY=10Gi -p STORAGE_CLASS_NAME=glusterfs-storage-block | oc create -f -
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


## Benchmark: [YCSB](https://github.com/brianfrankcooper/YCSB)

```sh
# curl -O -L https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/workloada.properties
# oc create configmap my-config --from-file=workloada.properties
# oc create -f TODO
```

```sh
$ ./bin/ycsb load mongodb -s -P workloads/workloada -p mongodb.url=mongodb://redhat:redhat@172.24.183.75:27017/testdb?w=0
```