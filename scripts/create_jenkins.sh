#!/bin/bash

readonly NAMESPACE_BASENAME=storage-test-git
readonly ITERATION=150
readonly TMP_FOLDER=/tmp/git-test

echo "NAMESPACE_BASENAME: ${NAMESPACE_BASENAME}"
echo "ITERATION: ${ITERATION}"
echo "TMP_FOLDER: ${TMP_FOLDER}"

readonly VOLUME_CAPACITY=3Gi
readonly STORAGE_CLASS_NAME=glusterfs-storage-block



for i in $(seq 101 ${ITERATION});
do
  echo "create ${i}..."
  NAMESPACE="${NAMESPACE_BASENAME}-${i}"
  oc new-project ${NAMESPACE} --skip-config-write=true
  oc process -f "${TMP_FOLDER}/files/oc/template_git.yaml" \
      -p PVC_SIZE=${VOLUME_CAPACITY} \
      -p STORAGE_CLASS_NAME=${STORAGE_CLASS_NAME} \
      | oc create --namespace=${NAMESPACE} -f -
  sleep 10
done
