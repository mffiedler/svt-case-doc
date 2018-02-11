#!/bin/bash

echo "001 $(date)"

readonly REMOTE_HOST=ip-172-31-1-36.us-west-2.compute.internal
pbench-register-tool-set --label=FIO
pbench-register-tool-set --label=FIO --remote="${REMOTE_HOST}"

echo "002 $(date)"

readonly CLIENT_HOST=172.21.0.5

pbench-fio --test-types=read,write,rw --clients="${CLIENT_HOST}" --config=SEQ_IO --samples=1 --max-stddev=20 --block-sizes=4,16,64 --job-file=config/sequential_io.job --pre-iteration-script=/root/svt/storage/scripts/drop-cache.sh

echo "003 $(date)"

pbench-fio --test-types=randread,randwrite,randrw --clients="${CLIENT_HOST}" --config=RAND_IO --samples=1 --max-stddev=20 --block-sizes=4,16,64 --job-file=config/random_io.job --pre-iteration-script=/root/svt/storage/scripts/drop-cache.sh


