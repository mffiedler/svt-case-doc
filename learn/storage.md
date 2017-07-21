# Storage

## Doc

* [Concepts](https://docs.openshift.org/latest/architecture/additional_concepts/storage.html)
* [Configure](https://docs.openshift.org/latest/install_config/persistent_storage/index.html)
* [Examples](https://docs.openshift.org/latest/install_config/storage_examples/index.html)


## Flexy and AWS
[Flexy](flexy.md) use <code>iaas_name: AWS</code> in [parameter template] to [configure master](https://docs.openshift.org/latest/install_config/configuring_aws.html#install-config-configuring-aws) to aws information.

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

## NFS

## AWS EBS
