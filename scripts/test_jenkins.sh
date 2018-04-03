#!/bin/bash

python -V

### Generate logs
rm -f ocp_logtest.py
curl -L -O https://raw.githubusercontent.com/openshift/svt/master/openshift_scalability/content/logtest/root/ocp_logtest.py

python ocp_logtest.py --line-length 128 --word-length 7 --rate 3000 --time 300 --fixed-line

### Generate artifacts
mkdir -p build
rm -rf build/*
rm -f *.tar.gz
dd if=/dev/zero of=build/output.dat1  bs=1M  count=128
dd if=/dev/zero of=build/output.dat2  bs=1M  count=128
curl -o build/penshift-origin-server-v3.9.0-191fece-linux-64bit.tar.gz https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-server-v3.9.0-191fece-linux-64bit.tar.gz

filename="build_${BUILD_TAG}_${BUILD_ID}"

echo "filename:${filename}."

tar -cvzf "${filename}.tar.gz" build


