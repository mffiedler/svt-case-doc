#!/bin/bash

python -V

curl -L -O https://raw.githubusercontent.com/openshift/svt/master/openshift_scalability/content/logtest/root/ocp_logtest.py

python ocp_logtest.py --line-length 128 --word-length 7 --rate 3000 --time 600 --fixed-line
