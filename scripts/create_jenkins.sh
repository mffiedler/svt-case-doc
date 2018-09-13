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


###
###
# grep finish pbench-user-benchmark_jenkins_storage_test_50_2_glusterfs-storage-block_6144Mi_2018.09.12T18.54.16/1/reference-result/result.txt | grep -v "not f" | awk '{print $NF}' | paste -sd+ | bc
# for i in {1..50}; do echo "index $i"; ll pbench-user-benchmark_jenkins_storage_test_50_2_glusterfs-storage-block_6144Mi_2018.09.12T18.54.16/1/reference-result/jenkins_result*brief* | cut -d "/" -f4 | grep "jenkins_result_run_storage-test-jenkins-${i}_" | wc -l; done
# for i in {1..100}; do echo $i; oc exec -n storage-test-jenkins-${i} $(oc get pod -n storage-test-jenkins-${i} | grep -v deploy | grep jenkins | awk '{print $1}') -- rm -rfv "/var/lib/jenkins/.m2/repository/"; done
# oc get pod --all-namespaces | grep jenkins | grep -v Running | awk '{print $1}' | while read i; do echo $i; oc delete rc -n $i jenkins-1; sleep 20; done
# grep -irn finish pbench-user-benchmark_jenkins_storage_test_50_2_glusterfs-storage-block_6144Mi_2018.09.12T18.54.16/1/reference-result/jenkins_result*brief* | grep -v "not finish" | awk '{print $NF}'  | paste -sd+ | bc
# for i in {51..200}; do oc delete project "storage-test-jenkins-$i" --wait=false; sleep 30; done
