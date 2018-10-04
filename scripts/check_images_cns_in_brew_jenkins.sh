#!/bin/bash

set -e

echo "now: $(TZ=":US/Eastern" date '+%Y-%m-%d %H:%M:%S %z')"

jq --version
skopeo --version
### docker --version
skopeo inspect --tls-verify=false docker://brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7 | jq .RepoTags | jq -r .[] | grep -v candidate | grep -v HOTFIX | sort -V

function check_brew_latest(){
  local image
  image=$1
  #echo "checking image: ${image}"
  local tag
  tag=$(skopeo inspect --tls-verify=false docker://brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/$image | jq .RepoTags | jq -r .[] | grep -v candidate | grep -v HOTFIX | sort -V | grep latest -B1 | head -n 1)
  echo "brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/$image:$tag"
}


echo "======latest images================"
check_brew_latest "rhgs3/rhgs-gluster-block-prov-rhel7"
check_brew_latest "rhgs3/rhgs-volmanager-rhel7"
check_brew_latest "rhgs3/rhgs-server-rhel7"
check_brew_latest "rhgs3/rhgs-s3-server-rhel7"
echo "==================================="

