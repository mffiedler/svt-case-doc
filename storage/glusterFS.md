# GlusterFS

## DOC

* [glusterFS@Wiki](https://en.wikipedia.org/wiki/GlusterFS)
* [gluster.org](https://www.gluster.org/)
* [glusterFS@oc](https://docs.openshift.com/container-platform/3.6/install_config/persistent_storage/persistent_storage_glusterfs.html)
    * containerized cluster, or containerized native storage (CNS): [containerized cluster](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/container-native_storage_for_openshift_container_platform_3.4/)
    * dedicated cluster

## CNS

### Installation

#### Ansible

Launch 5 EC2 instances:

```sh
aws ec2 run-instances --image-id ami-6ca0ba15 \
    --security-group-ids sg-5c5ace38 --count 5 --instance-type m4.xlarge --key-name id_rsa_perf \
    --subnet subnet-4879292d \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 30}},{\"DeviceName\":\"/dev/sdf\", \"Ebs\":{\"VolumeSize\": 30}}]" \
    --query 'Instances[*].InstanceId' \
    --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-bbb-0822\"}]}]"  
```

Note that block device <code>/dev/sdf</code> is managed by GlusterFS cluster.

Change the inventory file: 2.file

```
[OSEv3:children]
...
glusterfs


[OSEv3:vars]
...
glusterfs_devices=["/dev/xvdf"]
openshift_storage_glusterfs_wipe=true
openshift_storage_glusterfs_image=registry.access.redhat.com/rhgs3/rhgs-server-rhel7
openshift_storage_glusterfs_version=latest
openshift_storage_glusterfs_heketi_version=registry.access.redhat.com/rhgs3/rhgs-volmanager-rhel7
openshift_storage_glusterfs_heketi_version=latest
openshift_hosted_registry_glusterfs_swap=true

...
[glusterfs]
ec2-54-202-90-213.us-west-2.compute.amazonaws.com
ec2-54-200-102-250.us-west-2.compute.amazonaws.com
ec2-54-213-42-122.us-west-2.compute.amazonaws.com
```

[More parameters](https://github.com/openshift/openshift-ansible/tree/master/roles/openshift_storage_glusterfs) in the role <code>openshift_storage_glusterfs</code>.

#### [cns-deplay](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/container-native_storage_for_openshift_container_platform_3.4/ch04s02)
TODO

### Integration with OpenShift

## GlusterFS

### [Installation](https://access.redhat.com/documentation/en-US/Red_Hat_Storage/3/html/Administration_Guide/part-Red_Hat_Storage_Administration_on_Public_Cloud.html)

### Integration with OpenShift






## Reference
[1]. [RH Storage Server](https://access.redhat.com/documentation/en-US/Red_Hat_Storage/3/html/Administration_Guide/index.html)

[2]. [CNS: Architecture and configuration guide](https://www.redhat.com/cms/managed-files/st-container-native-storage-technology-detail-inc0464300at-201611-v2-en.pdf)
