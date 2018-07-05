# Google Compute Engine

## [Flexy control](https://docs.openshift.com/container-platform/3.9/install_config/configuring_gce.html)
ssh key: libra.pem

zone:

## aws vs gce

Libra key is not distributed to the hosts.
We can use `copy_libra_key.yaml` to do so.

subdomain and master public url

```sh
# grep subdomain /etc/origin/master/master-config.yaml 
  subdomain:  "0824-sob.qe.rhcloud.com"
# grep publicURL /etc/origin/master/master-config.yaml 
  publicURL: https://qe-hongkliu-ggg-0823-master-registry-router-nfs-1.0824-sob.qe.rhcloud.com:8443/console/
### Test on 201805
# grep -i publicURL /etc/origin/master/master-config.yaml
masterPublicURL: https://35.225.131.159:8443
```

storage class

```sh
# oc get sc
NAME                 PROVISIONER            AGE
standard (default)   kubernetes.io/gce-pd   42m
[root@hongkliu-310-aaa-master-etcd-1 ~]# oc get sc standard -o yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: "true"
  creationTimestamp: 2018-05-14T13:06:31Z
  name: standard
  resourceVersion: "1694"
  selfLink: /apis/storage.k8s.io/v1/storageclasses/standard
  uid: 9eb3889d-5777-11e8-9c4f-42010af00002
parameters:
  type: pd-standard
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Delete
volumeBindingMode: Immediate

# oc new-project aaa
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p PVC_NAME=pvc-aaa -p STORAGE_CLASS_NAME=standard | oc create -f -
# oc get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-aaa   Bound     pvc-d7d2f482-5787-11e8-9c4f-42010af00002   4G         RWO            standard       7m

### This pgName can be used to search as the key in Disks page on the web ui
# oc get pv pvc-d7d2f482-5787-11e8-9c4f-42010af00002 -o yaml | grep pdName
    pdName: kubernetes-dynamic-pvc-d7d2f482-5787-11e8-9c4f-42010af00002
```

On the gce UI, the type of the disk is `Standard persistent disk`. See [google cloud doc on disk type](https://cloud.google.com/compute/docs/disks/).

```sh
### which storage type is used for sc standard
# oc get sc standard -o yaml | grep type
  type: pd-standard
### use type pd-ssd: https://kubernetes.io/docs/concepts/storage/storage-classes/#gce
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/sc_gce_pd_ssd.yaml
# oc get sc
NAME                 PROVISIONER            AGE
ssd                  kubernetes.io/gce-pd   1m
standard (default)   kubernetes.io/gce-pd   2h

```

Some performance stats on the disk are listed in [google clould doc](https://cloud.google.com/compute/docs/disks/performance#ssd-pd-performance).

## [google cloud cli](https://cloud.google.com/sdk/docs/)

Installation

```sh
### Tested on Fedora 27 JN
$ mkdir gcpcli
$ cd gcpcli/
$ wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-200.0.0-linux-x86_64.tar.gz
$ tar -xzf google-cloud-sdk-200.0.0-linux-x86_64.tar.gz
$ cd ~/bin
$ ln -s ../gcpcli/google-cloud-sdk/bin/gcloud ./gcloud
$ gcloud init
$ gcloud config list
```

[How to use google cloud cli](https://cloud.google.com/sdk/gcloud/reference/).

List images:

```sh
$ gcloud compute images list | grep rhel-75 | tail -n 1
qe-rhel-75-20180507                                   openshift-gce-devel                                                READY
```

Create an instance:

```sh
$ gcloud compute instances create hongkliu-310-ttt       --image-family rhel-7 --image-project rhel-cloud       --zone us-central1-a
Created [https://www.googleapis.com/compute/v1/projects/openshift-gce-devel/zones/us-central1-a/instances/hongkliu-310-ttt].
NAME              ZONE           MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP     STATUS
hongkliu-310-ttt  us-central1-a  n1-standard-1               10.240.0.3   35.225.122.183  RUNNING

$ gcloud compute instances describe hongkliu-310-ttt


### generate ssh key pair if none exits
$ ssh-keygen -t rsa -b 4096 -C "liu@example.com"
Generating public/private rsa key pair.
Enter file in which to save the key (/home/fedora/.ssh/id_rsa): mykey

$ ll mykey*
-rw-------. 1 fedora fedora 3243 May 14 20:22 mykey
-rw-r--r--. 1 fedora fedora  741 May 14 20:22 mykey.pub

### the content is '''liu:$(cat mykey.pub)'''
### it would work too if it ends with 'liu@example.com', instead of 'liu'
$ cat list.txt
liu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzZLqKFNTbVR1cHKkMGGExG5GVsYsSOPpWO+dYi7kd6ToHlLjMuOGIdxMEkn9082TwE51fgG6nQEZPmiiesJ+EJuJLJdJ4H6tXdvE6sdSr/F93s3SpV+neIJTeFDKvlG7ayUArUQrL/Xi1qqYwBx6D9fil4OKbBodyqdHNpqP/PE74nj1riTcX1NOngF+Kh/tzzKYKA3FWQX++pEYtUmqumPhTiekbiinkSX3ZlYQddhbnWB37Dv4JM+4CEeLK3bZre/taj7kJ4OvMuwL6GBVGJ1J/Z/7cKUXl/Ygz45lz2OaPZlOoh7l0JQ18XJzTQTpNECjywVcFvkbpvxMKSafyaYX1OZN9+VH/M/xdfwt6KpqhvEURsJu3L5NHhxa0Db5sQ5qq71XVhe5Iacr5ZQOhksUq1BLN7hld4NlmnV1/dpuVqrSkWO72RL69g4XE3m4cvlrf8afugW6kZTn/5ii7hxm1h1NfCi20NPF2nGdwopBDBYwnS+aJv1GxgJfbiYmHXYM9x4oHUIcVW88QbOtbbVosg8xMOBwn0eIbuv0o6n75ptt+jFdl5jE3lmrJObAfEEKc2tJUiOLUweUC24u6TlFI+w1PkEEIznlPLdk5PtcEM0hutsHG9o9eh/YJH72SteqoNTOHSHPZIPzouRhktCir3wOzqAk0Nz+VpjwYvw== liu

### attach the pub key to the instance
$ gcloud compute instances add-metadata hongkliu-310-ttt --metadata-from-file ssh-keys=list.txt

$ ssh -i mykey liu@35.225.122.183
...
[liu@hongkliu-310-ttt ~]$
```

Note that the above method would not work for project images, tested with `qe-rhel-74-20180228`.
Flexy must have some magic to make it work.

### Disk

Create disks and attach them to the instances
```sh
$ gcloud compute disks create hongkliu-d1 hongkliu-d2 hongkliu-d3 --zone us-central1-a --size 256GB
$ gcloud compute instances attach-disk hongkliu-310-bbb-node-1 --disk hongkliu-d1 --zone us-central1-a
$ gcloud compute instances attach-disk hongkliu-310-bbb-node-2 --disk hongkliu-d2 --zone us-central1-a
$ gcloud compute instances attach-disk hongkliu-310-bbb-node-3 --disk hongkliu-d3 --zone us-central1-a

```

By default, the device is called `sdb`. Use `glusterfs_devices='["/dev/sdb"]'` in the inventory file.

## docker registry storage on gce
TODO
