#!/bin/bash

set -e

readonly ITERATION=10

readonly MONGO_IP=$(oc get svc -n ttt mongodb -o json | jq '.spec.clusterIP' --raw-output)

for i in $(seq 1 ${ITERATION});
do
  echo ${i}
  oc exec $(oc get pod -n ttt | grep ycsb | awk '{print $1}') -- ./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=100000 -p operationcount=100000 -p mongodb.url=mongodb://redhat:redhat@${MONGO_IP}:27017/testdb
  oc exec $(oc get pod -n ttt | grep m-cli | awk '{print $1}') -- mongo -u redhat -p redhat ${MONGO_IP}:27017/testdb --eval "db.usertable.remove({})"
done