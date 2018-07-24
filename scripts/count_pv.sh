#!/bin/bash

### curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/count_pv.sh
### chmod +x count_pv.sh
### * * * * * /root/count_pv.sh >> /tmp/pv.log
readonly PV_NUMBER=$(oc get pv --no-headers | wc -l)
readonly NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "${NOW} PV number is ${PV_NUMBER}"
