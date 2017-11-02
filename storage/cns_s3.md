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


$ s3curl.pl --id "personal" --createBucket -- http://gluster-s3-route-storage-project.apps.1102-nk6.qe.rhcloud.com/bkt-hk -v
*   Trying 54.201.47.141...
* TCP_NODELAY set
* Connected to gluster-s3-route-storage-project.apps.1102-nk6.qe.rhcloud.com (54.201.47.141) port 80 (#0)
> PUT /bkt-hk HTTP/1.1
> Host: gluster-s3-route-storage-project.apps.1102-nk6.qe.rhcloud.com
> User-Agent: curl/7.53.1
> Accept: */*
> Date: Thu, 02 Nov 2017 17:57:57 +0000
> Authorization: AWS testvolume:adminuser:iHUieFCgKdWwwn/mlgUcLkKUyuk=
> Content-Length: 0
> 
< HTTP/1.1 403 Forbidden
< x-amz-id-2: tx9a6615327f754a1b8cff7-0059fb5ca5
< x-amz-request-id: tx9a6615327f754a1b8cff7-0059fb5ca5
< Content-Type: application/xml
< X-Trans-Id: tx9a6615327f754a1b8cff7-0059fb5ca5
< Date: Thu, 02 Nov 2017 17:57:57 GMT
< Transfer-Encoding: chunked
< Set-Cookie: d99035b5f224fa6660b4f3d4264aaa1c=e7a41f869ca9b6435cdeb397f6f0c867; path=/; HttpOnly
* HTTP error before end of send, stop sending
< 
<?xml version='1.0' encoding='UTF-8'?>
* Closing connection 0
<Error><Code>SignatureDoesNotMatch</Code><Message>The request signature we calculated does not match the signature you provided. Check your key and signing method.</Message><RequestId>tx9a6615327f754a1b8cff7-0059fb5ca5</RequestId></Error>

```

TODO: Need to fix the authentication. 
