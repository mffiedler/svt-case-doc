#!/bin/bash

curl -o /data/job-template.yaml -L https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/docker/jjb/jobs/job-template.yaml

curl -o /data/defaults.yaml -L https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/docker/jjb/jobs/defaults.yaml

curl -o /data/projects.yaml -L https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/docker/jjb/jobs/projects.yaml
