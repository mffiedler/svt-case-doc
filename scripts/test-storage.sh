#!/bin/bash

echo "001 $(date)"

pbench-kill-tools
pbench-clear-tools
pbench-clear-results

pbench-register-tool-set --label=FIO
#readonly REMOTE_HOST=ip-172-31-1-36.us-west-2.compute.internal
#pbench-register-tool-set --label=FIO --remote="${REMOTE_HOST}"
oc get node  --no-headers | grep -v master | awk '{print $1}' | while read i; do pbench-register-tool-set --label=FIO --remote="${i}"; done

echo "002 $(date)"

readonly CLIENT_HOST=172.21.0.5

pbench-fio --test-types=read,write,rw --clients="${CLIENT_HOST}" --config=SEQ_IO --samples=1 --max-stddev=20 --block-sizes=4,16,64 --job-file=config/sequential_io.job --pre-iteration-script=/root/svt/storage/scripts/drop-cache.sh

echo "003 $(date)"

pbench-fio --test-types=randread,randwrite,randrw --clients="${CLIENT_HOST}" --config=RAND_IO --samples=1 --max-stddev=20 --block-sizes=4,16,64 --job-file=config/random_io.job --pre-iteration-script=/root/svt/storage/scripts/drop-cache.sh

echo "pbench-copy-results: $(date)"

pbench-copy-results