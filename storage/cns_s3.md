# [CNS S3](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.3/html-single/container-native_storage_for_openshift_container_platform/#S3_Object_Store)


```sh
# cns-deploy topology.json --deploy-gluster  --namespace storage-project --yes --log-file=/tmp/444-cns-deploy.log --object-account testvolume --object-user adminuser --object-password itsmine --verbose

# oc get pvc
NAME                    STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS       AGE
gluster-s3-claim        Bound     pvc-db246425-bfe6-11e7-a214-02777ccf87f4   2Gi        RWX           glusterfs-for-s3   1h
gluster-s3-meta-claim   Bound     pvc-db260419-bfe6-11e7-a214-02777ccf87f4   1Gi        RWX           glusterfs-for-s3   1h
root@ip-172-31-16-118: ~ # oc get route 
NAME               HOST/PORT                                                       PATH      SERVICES             PORT      TERMINATION   WILDCARD
gluster-s3-route   gluster-s3-route-storage-project.apps.1102-nk6.qe.rhcloud.com             gluster-s3-service   <all>                   None

```
