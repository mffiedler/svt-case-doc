# Azure

[instance types](https://azure.microsoft.com/en-ca/pricing/details/virtual-machines/linux/), [linux vm doc](https://docs.microsoft.com/en-us/azure/virtual-machines/)
[storage types](https://azure.microsoft.com/en-ca/pricing/details/storage/), [storage doc](https://docs.microsoft.com/en-us/azure/storage/)


[openshift on azure](https://docs.openshift.com/container-platform/3.9/install_config/configuring_azure.html),
oc PV on azure: [azure disk](https://docs.openshift.com/container-platform/3.9/install_config/persistent_storage/persistent_storage_azure.html),
[azure file](https://docs.openshift.com/container-platform/3.9/install_config/persistent_storage/persistent_storage_azure_file.html)

[k8s storage classes on azure](https://kubernetes.io/docs/concepts/storage/storage-classes/): seems to support more sc

## Azure cli

[installation doc](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum?view=azure-cli-latest)

## Flexy
ssh key: libra.pem

## aws vs azure

Libra key is not distributed to the hosts.
We can use `copy_libra_key.yaml` to do so.

```sh
# grep subdomain /etc/origin/master/master-config.yaml
  subdomain: apps.0515-xog.qe.rhcloud.com
# grep -i publicURL /etc/origin/master/master-config.yaml
masterPublicURL: https://hongk-master-etcd-nfs-1.centralus.cloudapp.azure.com:8443
  assetPublicURL: https://hongk-master-etcd-nfs-1.centralus.cloudapp.azure.com:8443/console/
  masterPublicURL: https://hongk-master-etcd-nfs-1.centralus.cloudapp.azure.com:8443
```

The public url does not work: [bz 1578539](https://bugzilla.redhat.com/show_bug.cgi?id=1578539). Fixed in 3.10.0-0.54.0.git.0.00a8b84.el7.

Storage

```sh
# oc get sc
NAME                       PROVISIONER                AGE
azure-standard (default)   kubernetes.io/azure-disk   1h
# oc get sc azure-standard -o yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: "true"
  creationTimestamp: 2018-05-15T19:00:14Z
  name: azure-standard
  resourceVersion: "1704"
  selfLink: /apis/storage.k8s.io/v1/storageclasses/azure-standard
  uid: 3396cd56-5872-11e8-ba0d-000d3a93937b
parameters:
  kind: Shared
  storageaccounttype: Standard_LRS
provisioner: kubernetes.io/azure-disk
reclaimPolicy: Delete
volumeBindingMode: Immediate

```

So the above one is `kubernetes.io/azure-disk` which is [New Azure Disk Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/#new-azure-disk-storage-class-starting-from-v1-7-2).

```sh
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p PVC_NAME=aaa1 -p STORAGE_CLASS_NAME=azure-standard | oc create -f -
# oc get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
aaa1      Bound     pvc-6eb005cf-5882-11e8-8cc1-000d3a93937b   3Gi        RWO            azure-standard   35m
# oc get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                 STORAGECLASS     REASON    AGE
pvc-6eb005cf-5882-11e8-8cc1-000d3a93937b   3Gi        RWO            Delete           Bound     aaa/aaa1              azure-standard             52m
# oc get pv pvc-6eb005cf-5882-11e8-8cc1-000d3a93937b -o yaml | grep diskName
    diskName: kubernetes-dynamic-pvc-6eb005cf-5882-11e8-8cc1-000d3a93937b
```

How can we get this disk on azure portal? There must be a better way.

First, on azure every storage object is associated with a storage account.
When we create the cluster, we have this in flexy:

```
resource_group: openshift-qe-centralus
```

There are 4 storage accounts in the above resource_group. Check `Properties` of
each of them. Only one (called `ds6eb4d9f5588211e884a30`) is `CREATED` today.

So far so good ... in `Overview`, click `Blobs` in the `Services` section. Now we can
see `vhds`, then click it. We will see `kubernetes-dynamic-pvc-6eb005cf-5882-11e8-8cc1-000d3a93937b.vhd`
is listed and its size matches too. BTW, its type is `Page blob`.

We can use the same storage account to create the following sc [azure-file](https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-file):

```sh
# vi sc-azure-file.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: azure-file
provisioner: kubernetes.io/azure-file
parameters:
  skuName: Standard_LRS
  location: centralus
  storageAccount: ds6eb4d9f5588211e884a30

# oc create -f ./sc-azure-file.yaml
# oc get sc
NAME                       PROVISIONER                AGE
azure-file                 kubernetes.io/azure-file   3s
azure-standard (default)   kubernetes.io/azure-disk   3h

```

Understand [skuName](https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts#Sku)
and [accountType](https://msdn.microsoft.com/en-us/library/azure/hh264518.aspx).

```sh
### Following https://bugzilla.redhat.com/show_bug.cgi?id=1578583
# oc edit ClusterRole system:controller:persistent-volume-binder
# oc get ClusterRole system:controller:persistent-volume-binder -o yaml | grep -A 5 secrets
  - secrets
  verbs:
  - create
  - delete
  - get
- apiGroups:
```

```sh
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p PVC_NAME=bbb1 -p STORAGE_CLASS_NAME=azure-file | oc create -f -
# oc get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
aaa1      Bound     pvc-6eb005cf-5882-11e8-8cc1-000d3a93937b   3Gi        RWO            azure-standard   1h
bbb1      Bound     pvc-a5ba1252-643f-11e8-8603-000d3a968092   3Gi        RWO            azure-file       1m
```

[bz 1578583](https://bugzilla.redhat.com/show_bug.cgi?id=1578583).
Might need [those yum steps](https://docs.openshift.com/container-platform/3.9/install_config/persistent_storage/persistent_storage_azure_file.html#azure-file-before-you-begin).

How to find it in azure portal

```sh
# oc get pv pvc-a5ba1252-643f-11e8-8603-000d3a968092 -o yaml | grep shareName
    shareName: kubernetes-dynamic-pvc-a5ba1252-643f-11e8-8603-000d3a968092
```

In `Overview` of the above storage account, click `Files` in the `Services` section. Now we can
see `kubernetes-dynamic-pvc-a5ba1252-643f-11e8-8603-000d3a968092`.

## docker registry storage on azure
TODO
