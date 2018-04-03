#!/bin/bash

readonly JJB_POD=$(oc get pod -n ttt | grep jjb | awk '{print $1}')
readonly JENKINS_URL=$(oc get route -n ttt --no-headers | awk '{print $2}')

for i in $(seq 0 29); do oc exec -n ttt "${JJB_POD}" -- jenkins-jobs  delete test-${i}_job; done

oc exec -n ttt "${JJB_POD}" -- rm -f /data/*

oc exec -n ttt "${JJB_POD}" -- curl -L -o /data/download_job_files.sh https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/download_job_files.sh

oc exec -n ttt "${JJB_POD}" -- bash /data/download_job_files.sh

oc exec -n ttt "${JJB_POD}" -- jenkins-jobs --flush-cache  update --delete-old /data

function trigger()
{
  local url
  url=$1
  local job_name
  job_name=$2
  curl -k --user admin:password -X POST "https://${url}/job/${job_name}/build" --data-urlencode json='{"parameter": []}'
}


for i in $(seq 0 29); do trigger "${JENKINS_URL}" "test-${i}_job"; done

###TODO: check the result
