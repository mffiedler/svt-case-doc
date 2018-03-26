#!/bin/bash

echo "001 $(date)"

pbench-kill-tools
pbench-clear-tools
pbench-clear-results

pbench-register-tool-set --label=FIO
pbench-register-tool --name=oc

readonly NODES=($(oc get node  --no-headers | grep -v master | awk '{print $1}'))

for node in "${NODES[@]}"
do
  pbench-register-tool-set --label=FIO --remote="${node}"
done

echo "002 $(date)"

pbench-user-benchmark --config="mongo_storage_test_$(oc get pvc -n ttt --no-headers | awk '{print $6}')" -- bash ./test-mongo.sh

echo "pbench-copy-results: $(date)"

pbench-copy-results
