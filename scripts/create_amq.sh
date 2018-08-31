#!/bin/bash

set -e

readonly NAMESPACE_BASENAME=storage-test-amq
readonly ITERATION=250
readonly TMP_FOLDER=/tmp/amq-test

echo "NAMESPACE_BASENAME: ${NAMESPACE_BASENAME}"
echo "ITERATION: ${ITERATION}"
echo "TMP_FOLDER: ${TMP_FOLDER}"

readonly VOLUME_CAPACITY=1Gi
readonly STORAGE_CLASS_NAME=glusterfs-storage


for i in $(seq 101 ${ITERATION});
do
  echo "create ${i}..."
  NAMESPACE="${NAMESPACE_BASENAME}-${i}"
  oc new-project ${NAMESPACE} --skip-config-write=true
  oc process -f "${TMP_FOLDER}/files/oc/amq63-persistent-template.yaml" \
      -p MQ_PROTOCOL=openwire,amqp,stomp,mqtt \
      -p MQ_USERNAME=redhat -p MQ_PASSWORD=redhat \
      -p AMQ_QUEUE_MEMORY_LIMIT=1mb \
      -p VOLUME_CAPACITY=${VOLUME_CAPACITY} \
      -p STORAGE_CLASS_NAME=${STORAGE_CLASS_NAME} \
      | oc create --namespace=${NAMESPACE} -f -

  oc create -n "${NAMESPACE}" -f ${TMP_FOLDER}/files/oc/dc_amq_perf.yaml
done


