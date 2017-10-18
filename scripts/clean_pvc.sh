#!/bin/bash


function print_usage {
  echo "usage: $0 <project_name> <interval_seconds>"
  echo "eg, $0 fioatest0 3"
}

if [ "$#" -ne 2 ]; then
  print_usage
  exit 1
fi

oc get pvc -n fiodtest0 --no-headers | cut -f1 -d" " | while read i; 
do 
  echo "$i"
  oc delete pvc -n "$1" "$i"
  sleep "$2"
done
