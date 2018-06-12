#!/bin/bash

### sudo yum install -y datamash

curl -s $1 | grep finished | sed 's/^.*storage/storage/' | awk '{print $6}' | datamash --header-out count 1 mean 1 median 1

