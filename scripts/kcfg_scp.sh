#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "No arguments supplied"
  exit 1
fi

readonly EC2_HOST=$1

scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "${HOME}/id_rsa_perf" "root@${EC2_HOST}:/etc/origin/master/admin.kubeconfig" "${HOME}/.kube/config"
