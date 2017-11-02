# [CNS S3](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.3/html-single/container-native_storage_for_openshift_container_platform/#S3_Object_Store)

## Installation

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

## Check with object operations

```sh
$ wget http://s3.amazonaws.com/doc/s3-example-code/s3-curl.zip
$ sudo dnf install perl-Digest-HMAC
$ vi ~/.s3curl
%awsSecretAccessKeys = (
    # personal account
    personal => {
        id => 'testvolume:adminuser',
        key => 'itsmine',
    },

    # corporate account
    company => {
        id => 'secret',
        key => 'secret',
    },
);


$ s3curl.pl --id "personal" --createBucket -- http://s3.amazonaws.com/bkt-hk -v
*   Trying 52.216.1.115...
* TCP_NODELAY set
* Connected to s3.amazonaws.com (52.216.1.115) port 80 (#0)
> PUT /bkt-hk HTTP/1.1
> Host: s3.amazonaws.com
> User-Agent: curl/7.53.1
> Accept: */*
> Date: Thu, 02 Nov 2017 17:54:38 +0000
> Authorization: AWS testvolume:adminuser:n8Ah7AOP4NsW5I4L/jzyRdsMvq8=
> Content-Length: 0
> 
< HTTP/1.1 400 Bad Request
< x-amz-request-id: 9276445EB326A48D
< x-amz-id-2: 0a9E5rouhpvyNGNOAHtO7Zgubc6KcncbM1K1nXZTf6O0TVfhNAYczbaBru2DhFnSgYOUySxlNVY=
< Content-Type: application/xml
< Transfer-Encoding: chunked
< Date: Thu, 02 Nov 2017 17:54:38 GMT
< Connection: close
< Server: AmazonS3
< 
<?xml version="1.0" encoding="UTF-8"?>
* Closing connection 0
<Error><Code>InvalidArgument</Code><Message>AWS authorization header is invalid.  Expected AwsAccessKeyId:signature</Message><ArgumentName>Authorization</ArgumentName><ArgumentValue>AWS testvolume:adminuser:n8Ah7AOP4NsW5I4L/jzyRdsMvq8=</ArgumentValue><RequestId>9276445EB326A48D</RequestId><HostId>0a9E5rouhpvyNGNOAHtO7Zgubc6KcncbM1K1nXZTf6O0TVfhNAYczbaBru2DhFnSgYOUySxlNVY=</HostId></Error>
```

Bz 
