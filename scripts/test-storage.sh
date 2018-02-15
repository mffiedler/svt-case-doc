#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <client_ip>"
  exit 1
fi

echo "001 $(date)"

pbench-kill-tools
pbench-clear-tools
pbench-clear-results

pbench-register-tool-set --label=FIO

readonly NODES=($(oc get node  --no-headers | grep -v master | awk '{print $1}'))

for node in "${NODES[@]}"
do
  pbench-register-tool-set --label=FIO --remote="${node}"
done

echo "002 $(date)"

readonly CLIENT_HOST=$1

pbench-fio --test-types=read,write,rw --clients="${CLIENT_HOST}" --config=SEQ_IO --samples=1 --max-stddev=20 --block-sizes=4,16,64 --job-file=config/sequential_io.job --pre-iteration-script=/root/svt/storage/scripts/drop-cache.sh

echo "003 $(date)"

pbench-fio --test-types=randread,randwrite,randrw --clients="${CLIENT_HOST}" --config=RAND_IO --samples=1 --max-stddev=20 --block-sizes=4,16,64 --job-file=config/random_io.job --pre-iteration-script=/root/svt/storage/scripts/drop-cache.sh

echo "pbench-copy-results: $(date)"

pbench-copy-results
