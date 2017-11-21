#!/bin/bash

### Do oc login https://api.reg-aws.openshift.com --token=<token> before running this script
### https://console.reg-aws.openshift.com/console/command-line
### Ref,: https://github.com/openshift/ops-sop/blob/master/services/opsregistry.asciidoc#using-the-registry-manually-using-rh-sso-user

function print_usage {
  echo "usage: $0 <username> <image_name>"
  echo "eg, $0 hongkliu@redhat.com openshift3/ose-deployer"
}

if [[ "$#" -ne 2 ]]; then
  print_usage
  exit 1
fi

readonly USERNAME=$1
readonly IMAGE_NAME=$2

#docker login -u ${USERNAME} -p $(oc whoami -t) registry.reg-aws.openshift.com:443

readonly OC_USER=$(oc whoami)

echo "aaa: ${OC_USER}"
echo "bbb: ${IMAGE_NAME}"

if [[ -z ${OC_USER} ]]; then
  echo "Do oc-login first"
  exit 1
fi

if [[ "${OC_USER}" != "${USERNAME}" ]]; then
  echo "not the same user: ${OC_USER} and ${USERNAME}"
  exit 1
fi

if [[ "${IMAGE_NAME}" != *"/"* ]]; then
    echo "image name: aaa/bbb"
  exit 1
fi

readonly NAMESPACE=${IMAGE_NAME%/*}
readonly IMAGE=${IMAGE_NAME#*/}

echo "ccc: ${NAMESPACE}"
echo "ddd: ${IMAGE}"

readonly LATEST_IMAGE_TAG=$(oc get is -n ${NAMESPACE} ${IMAGE} -o yaml | grep "tag:" | cut -f2 -d":" | sort -V | tail -n 1)

echo "latest tag of ${IMAGE_NAME}: ${LATEST_IMAGE_TAG}"