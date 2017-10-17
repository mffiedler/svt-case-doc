#!/bin/bash

## declare an array variable
#declare -a arr=("element1" "element2" "element3")
declare -a arr=("i-0ce08957ad9a590af" "i-0d2e1345b6441d7bd" "i-0fe0a25fe57ebda48" "i-026690af8a9fd3553" "i-029c615349b868a3f" "i-0b38774ec829106cd" "i-0c5d86d2abf6fa22c" "i-0e36ce214036834b3" "i-04e0808452f9a1076" "i-01b0f2ec5b8672554")

## now loop through the above array
for i in "${arr[@]}"
do
   echo "$i"
   # or do whatever with individual element of the array
   aws ec2  create-tags --resources "${i}" --tags "Key=KubernetesCluster,Value=qe-hongkliu-ttt-glusterfs-test"
done

