# GlusterFS test

## PVC only

### Run test

```sh
# oc get storageclass 
NAME                TYPE
glusterfs-storage   kubernetes.io/glusterfs   
gp2 (default)       kubernetes.io/aws-ebs

# cd svt/openshift_scalability
# #change the storage class name in content/pvc-templates/pvc-parameters.yaml
# vi content/pvc-templates/pvc-parameters.yaml
...
parameters:
          - STORAGE_CLASS: "glusterfs-storage"
...

# python -u cluster-loader.py -v -f content/pvc-templates/pvc-parameters.yaml
```

### Check results

## Pods with pvc

### Run test

```sh
# vi content/fio/fio-parameters.yaml
...
        parameters:
          - STORAGE_CLASS: "glusterfs-storage" # this is name of storage class to use
          - STORAGE_SIZE: "3Gi" # this is size of PVC mounted inside pod
          - MOUNT_PATH: "/mydata"
          - DOCKER_IMAGE: "openshift/hello-openshift"

...

# python -u cluster-loader.py -v -f content/fio/fio-parameters.yaml
```

### Check results
