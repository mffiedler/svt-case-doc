# Storage

## Doc

* [Concepts](https://docs.openshift.org/latest/architecture/additional_concepts/storage.html)
* [Configure](https://docs.openshift.org/latest/install_config/persistent_storage/index.html)
* [Examples](https://docs.openshift.org/latest/install_config/storage_examples/index.html)
* [Storage@k8s](https://kubernetes.io/docs/concepts/storage/volumes/)


## Flexy and AWS
[Flexy](flexy.md) uses <code>iaas_name: AWS</code> in [parameter template](http://git.app.eng.bos.redhat.com/git/openshift-misc.git/plain/v3-launch-templates/system-testing/aos-36/aws/vars.ose36-aws-svt.yaml) to get AWS information and to [configure master](https://docs.openshift.org/latest/install_config/configuring_aws.html#install-config-configuring-aws).

```sh
# cat /etc/origin/master/master-config.yaml | grep -i aws
# cat /etc/origin/cloudprovider/aws.conf
# cat /etc/sysconfig/atomic-openshift-master
```

## Volume provision

* [Static](https://docs.openshift.org/latest/install_config/persistent_storage/index.html): e.g, [AWS EBS](https://docs.openshift.org/latest/install_config/persistent_storage/persistent_storage_aws.html)
* [Dynamic](https://docs.openshift.org/latest/install_config/persistent_storage/dynamically_provisioning_pvs.html)

## Practice

### Dynamic provision with AWS EBS

```sh
# oc get storageclass 
NAME            TYPE
gp2 (default)   kubernetes.io/aws-ebs
```
It shows that we can claim aws-ebs volumes dynamically.

### create EBS pvc

```sh
# vi /tmp/pvc_ebs.yaml
kind: "PersistentVolumeClaim"
apiVersion: "v1"
metadata:
  name: "pvc-ebs"
spec:
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: "1Gi"
  storageClassName: gp2

# oc create -f  /tmp/pvc_ebs.yaml 
persistentvolumeclaim "pvc-ebs" created
# oc get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS      CLAIM         STORAGECLASS   REASON    AGE
pvc-223bfa0b-6e5c-11e7-827b-0264af681eb2   1Gi        RWO           Delete          Bound       aaa/pvc-ebs   gp2                      3s
root@ip-172-31-44-213: /tmp # oc get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
pvc-ebs   Bound     pvc-223bfa0b-6e5c-11e7-827b-0264af681eb2   1Gi        RWO           gp2            10s
```

#### [use PVC in pod](https://docs.openshift.org/latest/architecture/additional_concepts/storage.html#pvc-claims-as-volumes)

```sh
# oc new-app --docker-image="docker.io/hongkailiu/test-docker:latest"
# oc edit dc test-docker
      ...
      containers:
        ...
        volumeMounts:
        - mountPath: /mydata
          name: ddd  
      volumes:
      - name: ddd
        persistentVolumeClaim:
          claimName: pvc-ebs

# oc volumes po/test-docker-3-nmm4r
pods/test-docker-3-nmm4r
  pvc/pvc-ebs (allocated 1GiB) as ddd
    mounted at /mydata
  secret/default-token-m5hfx as default-token-m5hfx
    mounted at /var/run/secrets/kubernetes.io/serviceaccount

# oc exec test-docker-3-nmm4r -- tail /mydata/run.log
Sat Jul 22 04:41:15 UTC 2017
Sat Jul 22 04:41:16 UTC 2017
Sat Jul 22 04:41:17 UTC 2017

```

Also read [volume security](https://docs.openshift.org/latest/install_config/persistent_storage/pod_security_context.html).

### NFS

#### set up an NFS server
In the test cases [1], a service supported by a pod provides the NFS server.

Because <code>StorageClass</code> is set to [default](https://docs.openshift.org/latest/architecture/additional_concepts/storage.html#pvc-storage-class), let us set another one for NFS volume.

### [create NFS storageclass](https://docs.openshift.org/latest/install_config/storage_examples/storage_classes_legacy.html)

```sh
# vi /tmp/sc_nfs.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: mynfs 
provisioner: no-provisioning 
parameters:

#  oc create -f /tmp/sc_nfs.yaml 
storageclass "mynfs" created
# oc get storageclass 
NAME            TYPE
gp2 (default)   kubernetes.io/aws-ebs   
mynfs           no-provisioning
```

#### create NFS PV

```sh
# vi /tmp/pv_nfs.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 5Gi
  nfs:
    path: /
    server: 172.24.1.59
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: mynfs

# oc create -f /tmp/pv_nfs.yaml
persistentvolume "pv-nfs" created
# oc get pv
NAME      CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
pv-nfs    5Gi        RWX           Recycle         Available             mynfs                    14m
```
The <code>server</code> is the NFS server ip.

#### create NFS PVC

```sh
# vi /tmp/pvc_nfs.yaml 
kind: "PersistentVolumeClaim"
apiVersion: "v1"
metadata:
  name: "pvc-nfs"
  annotations:
    volume.alpha.kubernetes.io/storage-class: "mynfs"
spec:
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: "1Gi"
  storageClassName: mynfs

# oc create -f /tmp/pvc_nfs.yaml 
persistentvolumeclaim "pvc-nfs" created
# oc get pvc
NAME      STATUS    VOLUME    CAPACITY   ACCESSMODES   STORAGECLASS   AGE
pvc-nfs   Pending                                      mynfs          7m
```

*Error*: status is *PENDING*.


## Reference
1. [tsms case 499636](https://tcms.engineering.redhat.com/case/499636/?from_plan=14587)
