# Storage

## Doc

* [Concepts](https://docs.openshift.org/latest/architecture/additional_concepts/storage.html)
* [Configure](https://docs.openshift.org/latest/install_config/persistent_storage/index.html)
* [Examples](https://docs.openshift.org/latest/install_config/storage_examples/index.html)


## Flexy and AWS
[Flexy](flexy.md) uses <code>iaas_name: AWS</code> in [parameter template](http://git.app.eng.bos.redhat.com/git/openshift-misc.git/plain/v3-launch-templates/system-testing/aos-36/aws/vars.ose36-aws-svt.yaml) to [configure master](https://docs.openshift.org/latest/install_config/configuring_aws.html#install-config-configuring-aws) to aws information.

```sh
# cat /etc/origin/master/master-config.yaml | grep -i aws
# cat /etc/origin/cloudprovider/aws.conf
# cat /etc/sysconfig/atomic-openshift-master
```

## Volume provision

* [Static](https://docs.openshift.org/latest/install_config/persistent_storage/index.html): e.g, [AWS EBS](https://docs.openshift.org/latest/install_config/persistent_storage/persistent_storage_aws.html)
* [Dynamic](https://docs.openshift.org/latest/install_config/persistent_storage/dynamically_provisioning_pvs.html)

## Practice

### NFS

#### set up an NFS server
In the test cases [1], a service supported by a pod provides the NFS server.

#### create NFS PV

```sh
# cat /tmp/nfs-aaa.json 
{
  "apiVersion": "v1",
  "kind": "PersistentVolume",
  "metadata": {
    "name": "nfs-aaa"
  },
  "spec": {
    "capacity": {
        "storage": "5Gi"
    },
    "accessModes": [ "ReadWriteMany" ],
    "nfs": {
        "path": "/",
        "server": "172.24.1.59"
    },
    "persistentVolumeReclaimPolicy": "Recycle"
  }
}
```

The <code>server</code> is the NFS server ip.



### Dynamic provision with AWS EBS

```sh
# oc get storageclass 
NAME            TYPE
gp2 (default)   kubernetes.io/aws-ebs
```

It shows that we can claim aws-ebs volumes dynamically.




## Reference
1. [tsms case 499636](https://tcms.engineering.redhat.com/case/499636/?from_plan=14587)
