# Operators for OCP Storage system

## Doc

* [epic@jira](https://jira.coreos.com/browse/PROD-597)
* [introducing-volume-snapshot-alpha-for-kubernetes](https://kubernetes.io/blog/2018/10/09/introducing-volume-snapshot-alpha-for-kubernetes/)
* [Flex volume](https://itnext.io/how-to-create-a-custom-persistent-volume-plugin-in-kubernetes-via-flexvolume-part-1-f6d9d966e123)
* [kubernetes-csi/docs](https://github.com/kubernetes-csi/docs), [oc-csi](https://docs.openshift.com/container-platform/3.11/install_config/persistent_storage/persistent_storage_csi.html)
* [gluster/gluster-csi-driver](https://github.com/gluster/gluster-csi-driver) 
* block-volume: [BV@oc](https://docs.openshift.com/container-platform/3.11/architecture/additional_concepts/storage.html#block-volume-support), [BV@k8s](https://www.youtube.com/watch?v=k8_QQ9eNa-g)
* [External PV Provisioners](https://docs.openshift.com/container-platform/3.11/install_config/provisioners.html), [external-storage: aws/efs](https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs)
* sc: local: [local@k8s](https://kubernetes.io/docs/concepts/storage/storage-classes/#local); [local@oc](https://docs.openshift.com/container-platform/3.11/install_config/configuring_local.html)
* [aws: ebs vs efs](https://n2ws.com/blog/ebs-snapshot/aws-fast-storage-efs-vs-ebs), [efs.doc](https://docs.aws.amazon.com/efs/latest/ug/using-fs.html)

## PV using local storage

Add a 100G block device to an instance: [steps](../cloud/ec2/ec2.md#useful-commands).

```bash
# lsblk 
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
...
nvme2n1     259:4    0  100G  0 disk 

### add 2 partitions on /dev/nvme2n1
# fdisk /dev/nvme2n1
# cat /proc/partitions 
major minor  #blocks  name
...
 259        4  104857600 nvme2n1
 259        5   31457280 nvme2n1p1
 259        6   73399296 nvme2n1p2

# mkfs.ext4 /dev/nvme2n1p1
# mkdir -p /mnt/local-storage/ssd/disk1
# echo "/dev/nvme2n1p1 /mnt/local-storage/ssd/disk1 ext4 defaults 1 2" >> /etc/fstab
# mount -a

```

Follow the steps in [oc doc](https://docs.openshift.com/container-platform/3.11/install_config/configuring_local.html):

```bash
# chcon -R unconfined_u:object_r:svirt_sandbox_file_t:s0 /mnt/local-storage/


# oc new-project local-storage
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/local_volume_config_cm.yaml
# oc create serviceaccount local-storage-admin
# oc adm policy add-scc-to-user privileged -z local-storage-admin
# oc create -f https://raw.githubusercontent.com/openshift/origin/release-3.11/examples/storage-examples/local-examples/local-storage-provisioner-template.yaml

# oc new-app -p CONFIGMAP=local-volume-config \
  -p SERVICE_ACCOUNT=local-storage-admin \
  -p NAMESPACE=local-storage \
  -p PROVISIONER_IMAGE=registry.reg-aws.openshift.com:443/openshift3/local-storage-provisioner:v3.11 \
  local-storage-provisioner

# oc get all
NAME                                 READY     STATUS    RESTARTS   AGE
pod/local-volume-provisioner-9zj8j   1/1       Running   0          9s

NAME                                      DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/local-volume-provisioner   1         1         1         1            1           <none>          9s

# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/local_ssd_sc.yaml

# oc get sc local-ssd
NAME        PROVISIONER                    AGE
local-ssd   kubernetes.io/no-provisioner   16s
```

[Creating Local Persistent Volume Claim](https://docs.openshift.com/container-platform/3.11/install_config/persistent_storage/persistent_storage_local.html#install-config-persistent-storage-persistent-storage-local):

```bash
### create PVC
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p STORAGE_CLASS_NAME=local-ssd -p PVC_NAME=abc | oc create -f -
# oc get pvc
NAME      STATUS    VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
abc       Pending                                       local-ssd      1m

### The PVC will be pending until a pod using it gets created
### https://kubernetes.io/blog/2018/04/13/local-persistent-volumes-beta/
### The above blog also states that local volume should work without the provisioner
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/dc_centos_with_pv.yaml

# oc get pod
NAME                             READY     STATUS    RESTARTS   AGE
centos-1-65vm5                   1/1       Running   0          2m
local-volume-provisioner-9zj8j   1/1       Running   0          39m

# oc get pvc
NAME      STATUS    VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS   AGE
abc       Bound     local-pv-7b774915   29Gi       RWO            local-ssd      14m

# oc get pv
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM               STORAGECLASS   REASON    AGE
local-pv-7b774915   29Gi       RWO            Delete           Bound     local-storage/abc   local-ssd                40m

```

Observation:

* The provisioner provided by Openshift is creating PV on requesting PVC with the storage class.
* The size is determined by the mount device, instead of the requested size in PVC yaml.

Clean up:

```bash
# oc delete dc centos
# oc delete pvc abc
# The PV will be deleted automatically
# oc get pv
No resources found.
# oc delete project local-storage

```

This local volume provisioner also supports to [provision raw block devices](https://docs.openshift.com/container-platform/3.11/install_config/configuring_local.html#local-volume-raw-block-devices).

## External provisioner

Currently it has on efs provisioner. 
Suppose we have an efs with fs-id: fs-2a886d82 (see [efs.md](../cloud/ec2/efs.md) for details).
The folder `/data/persistentvolumes` must exist on the efs.
Let us deploy the provision on opc (see [more vars](https://github.com/openshift/openshift-ansible/tree/release-3.11/roles/openshift_provisioners)):

```sh
# ansible-playbook -v -i /tmp/2.file \
      /root/openshift-ansible/playbooks/openshift-provisioners/config.yml \
     -e openshift_provisioners_install_provisioners=True \
     -e openshift_provisioners_efs=True \
     -e openshift_provisioners_efs_fsid=fs-2a886d82 \
     -e openshift_provisioners_efs_region=us-west-2 \
     -e openshift_provisioners_efs_aws_access_key_id=<money> \
     -e openshift_provisioners_efs_aws_secret_access_key=<money> \
     -e openshift_provisioners_efs_path=/data/persistentvolumes

###pod is not running
# oc get pod -n openshift-infra

###Workaround: edit dc to use reg-aws reg
# oc get dc -n openshift-infra provisioners-efs -o yaml | grep image:
        image: registry.reg-aws.openshift.com:443/openshift3/efs-provisioner:latest

# oc get pod -n openshift-infra
NAME                       READY     STATUS    RESTARTS   AGE
provisioners-efs-2-sx8lg   1/1       Running   0          10m


# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/sc_aws_efs.yaml
# oc get sc aws-efs 
NAME      PROVISIONER             AGE
aws-efs   openshift.org/aws-efs   10s



```

Create a PVC with the sc `aws-efs` and a pod to use the PVC:

```bash
# oc delete project ttt
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p STORAGE_CLASS_NAME=aws-efs -p PVC_NAME=abc | oc create -f -
# oc get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
abc       Bound     pvc-98c1372a-d244-11e8-87bb-0212c16dd3de   3Gi        RWO            aws-efs        28s


# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/dc_centos_with_pv.yaml

# oc get pod
NAME             READY     STATUS    RESTARTS   AGE
centos-1-hrbrw   1/1       Running   0          19s
# oc rsh centos-1-hrbrw
sh-4.2$ df -hT | grep efs
fs-2a886d82.efs.us-west-2.amazonaws.com:/data/persistentvolumes/abc-pvc-98c1372a-d244-11e8-87bb-0212c16dd3de nfs4     8.0E     0  8.0E   0% /bbb

```


Uninstall:

```bash
# ansible-playbook -v -i /tmp/2.file /root/openshift-ansible/playbooks/openshift-provisioners/config.yml -e openshift_provisioners_install_provisioners=False
```

## CSI

## Volume Snapshot

## Operators for storage
