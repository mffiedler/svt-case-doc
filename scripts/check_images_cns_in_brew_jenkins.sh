#!/bin/bash

set -e

echo "now: $(TZ=":US/Eastern" date '+%Y-%m-%d %H:%M:%S %z')"

jq --version
skopeo --version
### docker --version

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

echo "======latest images================"
check_brew_latest "ocs/rhgs-gluster-block-prov-rhel7"
check_brew_latest "ocs/rhgs-volmanager-rhel7"
check_brew_latest "ocs/rhgs-server-rhel7"
check_brew_latest "ocs/rhgs-s3-server-rhel7"
echo "==================================="

function check_aws_reg_latest(){
  local image
  image=$1
  local tag
  tag=$(skopeo inspect --tls-verify=false --creds=aos-qe-pull36:${aws_reg_token} docker://registry.reg-aws.openshift.com:443/${image}:3.3 | jq .RepoTags | jq -r .[] | grep -v "candidate" | grep -v "manual" | grep -v "v" | sort -V | tail -n 1)
  echo "registry.reg-aws.openshift.com:443/${image}:${tag}"
}

if [[ -z "${aws_reg_token}" ]]; then
  echo "skipping aws-reg"
  exit 0
fi

echo "======latest images================"
check_aws_reg_latest "rhgs3/rhgs-gluster-block-prov-rhel7"
check_aws_reg_latest "rhgs3/rhgs-volmanager-rhel7"
check_aws_reg_latest "rhgs3/rhgs-server-rhel7"
check_aws_reg_latest "rhgs3/rhgs-s3-server-rhel7"
echo "==================================="

if [[ -z "${push_image}" ]]; then
  echo "skipping pushing image"
  exit 0
else
  echo "sync ${src-image} to ${target_image}.manual.push with user ${username}"
  skopeo copy docker://${src_image} docker://${target_image}.manual.push --dcreds ${username}:${password}
fi

