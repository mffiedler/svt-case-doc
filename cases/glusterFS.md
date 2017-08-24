# GlusterFS test

## Run test

```sh
# oc get storageclass 
NAME                TYPE
glusterfs-storage   kubernetes.io/glusterfs   
gp2 (default)       kubernetes.io/aws-ebs
# #change the storage class name in content/pvc-templates/pvc-parameters.yaml
# vi content/pvc-templates/pvc-parameters.yaml
...
parameters:
          - STORAGE_CLASS: "glusterfs-storage"
...

# cd svt/openshift_scalability
# python -u cluster-loader.py -z -f content/pvc-templates/pvc-parameters.yaml
```
