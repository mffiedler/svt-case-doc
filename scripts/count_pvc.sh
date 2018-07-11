#!/bin/bash

### curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/count_pvc.sh
### * * * * * /root/count_pvc.sh >> /tmp/pvc.log
readonly PVC_NUMBER=$(oc get pvc --all-namespaces --no-headers | grep Bound | wc -l)
readonly NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "${NOW} bound PVC number is ${PVC_NUMBER}"
