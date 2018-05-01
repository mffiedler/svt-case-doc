# Postgresql

## Prepare the pod

```
$ oc get template -n openshift postgresql-persistent -o yaml > /tmp/postgresql-persistent-template-ttt.yaml
$ oc process --parameters -f /tmp/postgresql-persistent-template-ttt.yaml
NAME                    DESCRIPTION                                                                  GENERATOR           VALUE
MEMORY_LIMIT            Maximum amount of memory the container can use.                                                  512Mi
NAMESPACE               The OpenShift Namespace where the ImageStream resides.                                           openshift
DATABASE_SERVICE_NAME   The name of the OpenShift Service exposed for the database.                                      postgresql
POSTGRESQL_USER         Username for PostgreSQL user that will be used for accessing the database.   expression          user[A-Z0-9]{3}
POSTGRESQL_PASSWORD     Password for the PostgreSQL connection user.                                 expression          [a-zA-Z0-9]{16}
POSTGRESQL_DATABASE     Name of the PostgreSQL database accessed.                                                        sampledb
VOLUME_CAPACITY         Volume space available for data, e.g. 512Mi, 2Gi.                                                1Gi
POSTGRESQL_VERSION      Version of PostgreSQL image to be used (9.4, 9.5, 9.6 or latest).                                9.6

# oc new-project ttt
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/postgresql-persistent-template-ttt.yaml -p MEMORY_LIMIT=4096Mi -p POSTGRESQL_USER=redhat -p POSTGRESQL_PASSWORD=redhat -p POSTGRESQL_DATABASE=sampledb -p VOLUME_CAPACITY=1000Gi -p STORAGE_CLASS_NAME=gp2 -p POSTGRESQL_VERSION=9.6 | oc create -f -
```

## Run the test

```sh
$ cd svt/storage/postgresql/
$ bash -x ./pgbench_test.sh -n ttt -t 100 -e empty -v empty -m ttt -i 5 --mode otherstorage -r /tmp/aaa --clients 10 --threads 2 --storageclass empty --scaling 10
```