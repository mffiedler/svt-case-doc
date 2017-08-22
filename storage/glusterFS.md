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

Run playbook (on master):
```sh
# ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/byo/config.yml
```

Check project <code>glusterfs</code>

```sh
# oc get all -n glusterfs -o wide
NAME                REVISION   DESIRED   CURRENT   TRIGGERED BY
dc/heketi-storage   1          1         1         config

NAME                  DESIRED   CURRENT   READY     AGE       CONTAINER(S)   IMAGE(S)                             SELECTOR
rc/heketi-storage-1   1         1         1         1h        heketi         rhgs3/rhgs-volmanager-rhel7:latest   deployment=heketi-storage-1,deploymentconfig=heketi-storage,glusterfs=heketi-storage-pod

NAME                    HOST/PORT                                       PATH      SERVICES         PORT      TERMINATION   WILDCARD
routes/heketi-storage   heketi-storage-glusterfs.54.245.157.96.xip.io             heketi-storage   heketi                  None

NAME                              CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE       SELECTOR
svc/heketi-db-storage-endpoints   172.24.85.211   <none>        1/TCP      1h        <none>
svc/heketi-storage                172.24.37.13    <none>        8080/TCP   1h        glusterfs=heketi-storage-pod

NAME                         READY     STATUS    RESTARTS   AGE       IP              NODE
po/glusterfs-storage-bm10c   1/1       Running   0          1h        172.31.48.172   ip-172-31-48-172.us-west-2.compute.internal
po/glusterfs-storage-pjz47   1/1       Running   0          1h        172.31.17.109   ip-172-31-17-109.us-west-2.compute.internal
po/glusterfs-storage-qsg6l   1/1       Running   0          1h        172.31.44.251   ip-172-31-44-251.us-west-2.compute.internal
po/heketi-storage-1-xmgdg    1/1       Running   0          1h        172.20.0.3      ip-172-31-44-251.us-west-2.compute.internal

# oc get storageclass glusterfs-storage -o yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  creationTimestamp: 2017-08-22T18:33:18Z
  name: glusterfs-storage
  resourceVersion: "5005"
  selfLink: /apis/storage.k8s.io/v1/storageclasses/glusterfs-storage
  uid: 5e1503ba-8768-11e7-975f-025caffb13f6
parameters:
  resturl: http://heketi-storage-glusterfs.54.245.157.96.xip.io
  restuser: admin
  secretName: heketi-storage-admin-secret
  secretNamespace: glusterfs
provisioner: kubernetes.io/glusterfs

```

_Note_ that

* Each _glusterfs_ node has <code>po/glusterfs-storage-*</code> and one of them has <code>po/heketi-storage-1-*</code>.
* SC _glusterfs-storage_ connects to rest api provided by heketi to provion storage. Check the route:

   ```sh
   # curl http://heketi-storage-glusterfs.54.245.157.96.xip.io
   Required authorization token not found
   ```

Create pvc (using [pvc_gluster.yaml](../files/pvc_gluster.yaml)) and use it in a pod ([pod_jenkins_volume.yaml](../files/pod_jenkins_volume.yaml)).

```sh
# oc new-project aaa
# oc create -f pvc_gluster.yaml
# oc get pvc
NAME          STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS        AGE
pvc-gluster   Bound     pvc-8744683b-8768-11e7-975f-025caffb13f6   1Gi        RWO           glusterfs-storage   17m
# oc get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM             STORAGECLASS        REASON    AGE
pvc-8744683b-8768-11e7-975f-025caffb13f6   1Gi        RWO           Delete          Bound     aaa/pvc-gluster   glusterfs-storage             18m

# #replace claimName: pvc-ebs by claimName: pvc-gluster
# oc create -f pod_jenkins_volume.yaml
# oc get pod 
NAME               READY     STATUS    RESTARTS   AGE
web                1/1       Running   0          1m
# oc volumes pod web
pods/web
  pvc/pvc-gluster (allocated 1GiB) as ddd
    mounted at /var/jenkins_home
  secret/default-token-gj7td as default-token-gj7td
    mounted at /var/run/secrets/kubernetes.io/serviceaccount
# #check if the data is written on the volume
# oc exec web -- ls /var/jenkins_home
```

#### [cns-deplay](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/container-native_storage_for_openshift_container_platform_3.4/ch04s02)
TODO

### Integration with OpenShift

## GlusterFS

### [Installation](https://access.redhat.com/documentation/en-US/Red_Hat_Storage/3/html/Administration_Guide/part-Red_Hat_Storage_Administration_on_Public_Cloud.html)

### Integration with OpenShift






## Reference
[1]. [RH Storage Server](https://access.redhat.com/documentation/en-US/Red_Hat_Storage/3/html/Administration_Guide/index.html)

[2]. [CNS: Architecture and configuration guide](https://www.redhat.com/cms/managed-files/st-container-native-storage-technology-detail-inc0464300at-201611-v2-en.pdf)
