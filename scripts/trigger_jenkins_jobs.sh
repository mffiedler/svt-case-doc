#!/bin/bash

readonly JJB_POD=$(oc get pod -n ttt | grep jjb | awk '{print $1}')
readonly JENKINS_URL=$(oc get route -n ttt --no-headers | awk '{print $2}')

for i in $(seq 0 29); do oc exec -n ttt "${JJB_POD}" -- jenkins-jobs  delete test-${i}_job; done

oc exec -n ttt "${JJB_POD}" -- rm -f /data/*

oc exec -n ttt "${JJB_POD}" -- curl -L -o /data/download_job_files.sh https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/download_job_files.sh

oc exec -n ttt "${JJB_POD}" -- bash /data/download_job_files.sh

sleep 23

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

function check_build() {
  local interval
  interval=$1
  local timeout
  timeout=$2
  local start_time
  start_time=$(date +%s)
  local result
  local all_success
  local j
  j=0
  while (( ($(date +%s) - ${start_time}) < ${timeout} ));
  do
    all_success=1
    for i in $(seq ${j} 29)
      do
        j=${i}
        result=$(curl -s -k --user admin:password https://${JENKINS_URL}/job/test-${i}_job/job/ttt/1/api/json | jq '.result' --raw-output)
        if [[ "${result}" != "SUCCESS" ]]; then
          echo "job ${i}: ${result}"
          all_success=0
          break
        fi
    done
    if (( ${all_success} == 1 ));
    then
      MY_TIME=$(($(date +%s) - ${start_time}))
      break
    fi
    sleep ${interval}
  done
}

MY_TIME=-1
readonly TIMEOUT=600
check_build 10 ${TIMEOUT}


if (( ${MY_TIME} == -1 ));
then
  echo "not finished in ${TIMEOUT} seconds"
  exit 1
else
  echo "All builds succeeded in ${MY_TIME} seconds"
  exit 0
fi


