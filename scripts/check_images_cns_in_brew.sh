#!/bin/bash

### require jq command: 'yum/dnf install jq' if command not found

function check_brew_latest(){
  local image
  image=$1
  echo "checking image: ${image}"
  curl -s -k brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/v1/repositories/${image}/tags | jq 'keys' | jq -r .[] | sort -V | grep latest -B1
}



check_brew_latest "rhgs3/rhgs-gluster-block-prov-rhel7"
check_brew_latest "rhgs3/rhgs-volmanager-rhel7"
check_brew_latest "rhgs3/rhgs-server-rhel7"
check_brew_latest "rhgs3/rhgs-s3-server-rhel7"



readonly GFS_TAG=3.3.1-10
readonly S3_TAG=3.3.1-7
readonly GFS_BP_TAG=3.3.1-7
readonly HKT_TAG=3.3.1-8

set -e

function sync_image(){
  docker docker pull "$1"
  docker tag "$1" "$2"
  docker push "$2"
}

if [[ "$1" == "sync" ]]; then
  echo "Start to sync ..."
  sync_image "brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7:${GFS_TAG}" "registry.reg-aws.openshift.com:443/rhgs3/rhgs-server-rhel7:${GFS_TAG}"
  sync_image "brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-s3-server-rhel7:${S3_TAG}" "registry.reg-aws.openshift.com:443/rhgs3/rhgs-s3-server-rhel7:${S3_TAG}"
  sync_image "brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-gluster-block-prov-rhel7:${GFS_BP_TAG}" "registry.reg-aws.openshift.com:443/rhgs3/rhgs-gluster-block-prov-rhel7:${GFS_BP_TAG}"
  sync_image "brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-volmanager-rhel7:${HKT_TAG}" "registry.reg-aws.openshift.com:443/rhgs3/rhgs-volmanager-rhel7:${HKT_TAG}"
fi
