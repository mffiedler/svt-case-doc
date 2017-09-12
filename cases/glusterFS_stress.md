# GlusterFS Stress test

Create 750 pods with pvc based on glusterfs.

## OpenShift gluster

See [mojo](https://mojo.redhat.com/docs/DOC-1138715) for node info.

| role         | type       | number |
|--------------|------------|--------|
| cns node     | m4.4xlarge | 3      |
| master node  | m4.xlarge  | 1      |
| infra node   | m4.xlarge  | 1      |
| compute node | m4.xlarge  | 3      |


Because the cns images have not been released yet, we have to upload them
manually. See [cns_internal.md](../storage/cns_internal.md) for details.

```sh
## create cns nodes with 3 1000g-volumes
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-6ca0ba15     --security-group-ids sg-5c5ace38 --count 3 --instance-type m4.4xlarge --key-name id_rsa_perf     --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 60}},{\"DeviceName\":\"/dev/sdf\", \"Ebs\":{\"VolumeSize\": 1000}},{\"DeviceName\":\"/dev/sdg\", \"Ebs\":{\"VolumeSize\": 1000}},{\"DeviceName\":\"/dev/sdh\", \"Ebs\":{\"VolumeSize\": 1000}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-bbb-test-0909\"}]}]"
[
    "i-0165db22e3696292e",
    "i-02d410a8be06f35e1",
    "i-0b11cb6de89905932"
]
## create other nodes
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-6ca0ba15     --security-group-ids sg-5c5ace38 --count 5 --instance-type m4.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 60}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-bbb-test-0909\"}]}]"[
    "i-047060dfb0eac057d",
    "i-011a7e89d81c5f4d0",
    "i-06f8115f1b7b63a83",
    "i-054aaea03b888a986",
    "i-05be81e44b58e4b6e"
]

## upload the following 2 cns images to cns nodes
## upload the following 1 cns image (rhgs-volmanager-rhel7) to compute nodes

## update subdomain and host names in inventory file
## use cns images with the following version

...
openshift_storage_glusterfs_image=brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7
openshift_storage_glusterfs_version=3.3.0-12
openshift_storage_glusterfs_heketi_image=brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-volmanager-rhel7
openshift_storage_glusterfs_heketi_version=3.3.0-9
...

# ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/byo/config.yml
```


## Move pods

By default, one compute node can run 250 pods.
The 750 test pods will run on 3 computing nodes. We need to move all existing
pods out of them. The Heketi pod require many compute resources so move it
to one of the cns nodes.

```sh
# oc edit dc/registry-console -n default
...
      dnsPolicy: ClusterFirst
      nodeSelector:
        region: infra
...

# oc edit dc/heketi-storage -n glusterfs
...
      dnsPolicy: ClusterFirst
      nodeSelector:
        glusterfs: storage-host
...
```

## Label compute nodes
Make sure the pods for test run only on compute nodes, instead of spreading
onto cns nodes.

```sh
# oc label node ip-172-31-56-64.us-west-2.compute.internal "aaa=bbb"
# oc label node ip-172-31-44-147.us-west-2.compute.internal "aaa=bbb"
# oc label node ip-172-31-23-200.us-west-2.compute.internal "aaa=bbb"
```

## Run test

```sh
# cd svt/openshift_scalability
# curl -o ./content/fio/fio-template2.json https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/fio-template2.json
# 3 projects, 150 templates
# vi content/fio/fio-parameters.yaml
...
        file: ./content/fio/fio-template2.json
        parameters:
          - STORAGE_CLASS: "glusterfs-storage" # this is name of storage class to use
          - STORAGE_SIZE: "1Gi" # this is size of PVC mounted inside pod
          - MOUNT_PATH: "/mnt/pvcmount"
          - DOCKER_IMAGE: "gcr.io/google_containers/pause-amd64:3.0"
...

# python -u cluster-loader.py -v -f content/fio/fio-parameters.yaml
```

## Watch results

```sh
# #open a new terminal
# watch -n 10 "oc get pv --no-headers | wc -l"
# #open a new terminal
# watch -n 10 "oc get pod --all-namespaces | grep fio | grep Runn | wc -l"
```

We will see the number of running pods are chasing up the number of PVs.
In 2 hours, we should be able to see 750 running pods.

## Debug

```
[heketi] ERROR 2017/09/09 16:18:28 /src/github.com/heketi/heketi/apps/glusterfs/app_volume.go:149: Failed to create volume: Error calling v.allocBricksInCluster: database is in read-only mode
```

If log of the heketi pod shows the above entry, then scale down/up via dc:

```sh
# oc scale --replicas=0 -n glusterfs dc/heketi-storage
# #wait until the heketi pod is deleted
# oc scale --replicas=1 -n glusterfs dc/heketi-storage
```

## 1000 pods
Label the 2 cns nodes where heketi does not run:

```sh
# oc get pods -n glusterfs -o wide
NAME                      READY     STATUS    RESTARTS   AGE       IP              NODE
glusterfs-storage-2cgbc   1/1       Running   0          5h        172.31.28.43    ip-172-31-28-43.us-west-2.compute.internal
glusterfs-storage-3c13z   1/1       Running   0          5h        172.31.1.45     ip-172-31-1-45.us-west-2.compute.internal
glusterfs-storage-pqpg4   1/1       Running   0          5h        172.31.31.233   ip-172-31-31-233.us-west-2.compute.internal
heketi-storage-2-dwsn5    1/1       Running   0          4h        172.20.1.3      ip-172-31-1-45.us-west-2.compute.internal
# oc label node ip-172-31-28-43.us-west-2.compute.internal "aaa=bbb"
# oc label node ip-172-31-31-233.us-west-2.compute.internal "aaa=bbb"
```

See the screenshot:

![](https://github.com/hongkailiu/svt-case-doc/raw/master/files/glusterfs_stress.png)

TODO: Adding one more compute node should lead to 1000 pods.
