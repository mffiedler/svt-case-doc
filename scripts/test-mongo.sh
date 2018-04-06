#!/bin/bash

set -e

readonly ITERATION=10

readonly MONGO_IP=$(oc get svc -n ttt mongodb -o json | jq '.spec.clusterIP' --raw-output)

for i in $(seq 1 ${ITERATION});
do
  echo ${i}
  oc exec $(oc get pod -n ttt | grep mongodb | awk '{print $1}') -- mongo -u redhat -p redhat ${MONGO_IP}:27017/testdb --eval "db.usertable.remove({})"
  oc exec $(oc get pod -n ttt | grep ycsb | awk '{print $1}') -- ./bin/ycsb load mongodb -s -threads 60 -P workloads/workload_template -p mongodb.url=mongodb://redhat:redhat@${MONGO_IP}:27017/testdb
done

