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
