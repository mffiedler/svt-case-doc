#!/bin/bash

set -e

readonly NAMESPACE_BASENAME=storage-test-jenkins
readonly ITERATION=10
readonly TMP_FOLDER=/tmp/jenkins-test

echo "NAMESPACE_BASENAME: ${NAMESPACE_BASENAME}"
echo "ITERATION: ${ITERATION}"
echo "TMP_FOLDER: ${TMP_FOLDER}"
readonly MEMORY_LIMIT="6144Mi"
readonly JENKINS_IMAGE_STREAM_TAG="jenkins:2"

readonly VOLUME_CAPACITY=3Gi
readonly STORAGE_CLASS_NAME=glusterfs-storage-block



for i in $(seq 2 ${ITERATION});
do
  echo "create ${i}..."
  NAMESPACE="${NAMESPACE_BASENAME}-${i}"
  oc new-project ${NAMESPACE} --skip-config-write=true
  oc process -f "${TMP_FOLDER}/files/oc/jenkins-persistent-template.yaml" \
      -p ENABLE_OAUTH=false -p MEMORY_LIMIT=${MEMORY_LIMIT} \
      -p VOLUME_CAPACITY=${VOLUME_CAPACITY} \
      -p STORAGE_CLASS_NAME=${STORAGE_CLASS_NAME} \
      -p JENKINS_IMAGE_STREAM_TAG=${JENKINS_IMAGE_STREAM_TAG} \
      | oc create --namespace=${NAMESPACE} -f -

  oc process -f ${TMP_FOLDER}/files/oc/cm_jjb_template.yaml \
      -p "JENKINS_URL=https://$(oc get route -n ${NAMESPACE} --no-headers | awk '{print $2}')" \
      | oc create -n "${NAMESPACE}" -f -
  oc create -n "${NAMESPACE}" -f ${TMP_FOLDER}/files/oc/dc_jjb.yaml
  sleep 10
done
