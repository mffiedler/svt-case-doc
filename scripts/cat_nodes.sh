#!/bin/bash

set -e

echo "[masters]"
oc get nodes -l region=infra | grep SchedulingDisabled | awk '{print $1}'

echo "[infra]"
oc get nodes -l region=infra | grep -v NAME  | awk '{print $1}'

echo "[computing_nodes]"
oc get nodes -l region=primary | grep -v NAME | awk '{print $1}'