# Build Project Delete Test

## Install bc if not yet

```sh
$ sudo dnf install -y bc
```

## Run the test


```sh
$ cd svt/openshift_performance/ci/scripts
### Create 1000 projects using cluster-loader
$ vi ../content/conc_proj.yaml
$ python ../../../openshift_scalability/cluster-loader.py -f ../content/conc_proj.yaml

### Check 1000 projects are created
### In other terminal
$ watch -n 10 "oc get project | grep clusterproject | wc -l"

### Delete projects and measure times
$ ./delete_projects.sh
...
Deletion Time - 172

### Create 5000 projects using cluster-loader

Deletion Time - 172

### Create 1000 projects with secrets etc. using cluster-loader
$ vi ../../../openshift_scalability/config/pyconfigLoadedProject.yaml
### Remove projects.{users|pods|templates.*deployment-config} sections
$ cd ../../../openshift_scalability/
$ python ./cluster-loader.py -f ./config/pyconfigLoadedProject.yaml

Deletion Time - 172

### Create 5000 projects with secrets etc. using cluster-loader:

Deletion Time - 172
```



