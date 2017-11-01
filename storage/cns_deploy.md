# CNS tool: cns-deploy

Use cns-deploy to deploy CNS on OCP. 

* Follow the doc [here](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.3/html-single/container-native_storage_for_openshift_container_platform/#chap-Documentation-Red_Hat_Gluster_Storage_Container_Native_with_OpenShift_Platform-Setting_the_environment-Deploy_CNS).
* Previous version of the doc is [here](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/container-native_storage_for_openshift_container_platform_3.4/ch04s02).
* [Keith Tenzer's blog](https://keithtenzer.com/2017/03/29/storage-for-containers-using-container-native-storage-part-iii/).

## Installation

### Install OpenShift cluster based on rhel AMIs
1 master, 1 infra, 3 compute nodes.

## Install the pkgs

Checking the package version (Oct 31, 2017)

```sh
# yum info cns-deploy heketi-client
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Available Packages
Name        : cns-deploy
Version     : 3.1.0
...
Name        : heketi-client
Version     : 4.0.0
```

Checking on brew: [cns-deploy](https://brewweb.engineering.redhat.com/brew/packageinfo?packageID=61728) and [heketi-*]( https://brewweb.engineering.redhat.com/brew/packageinfo?packageID=54317)

```
cns-deploy-5.0.0-54.el7rhgs
heketi-5.0.0-16.el7rhgs
```

Get latest packages and scp to master:

```sh
# pwd
/root/local_rpm_repo

# ll
total 11660
-rw-r--r--. 1 root root   32460 Oct 31 18:30 cns-deploy-5.0.0-54.el7rhgs.x86_64.rpm
-rw-r--r--. 1 root root 6311420 Oct 31 18:30 heketi-5.0.0-16.el7rhgs.x86_64.rpm
-rw-r--r--. 1 root root 5567652 Oct 31 18:30 heketi-client-5.0.0-16.el7rhgs.x86_64.rpm
-rw-r--r--. 1 root root   23708 Oct 31 18:30 python-heketi-5.0.0-16.el7rhgs.x86_64.rpm
```

Config this folder as a local yum repo. See the steps in [docker_version.md](../fix/docker_version.md).

```sh
# yum install -y cns-deploy heketi-client
```

Check images in templates:

```sh
# grep -ri rhgs /usr/share/heketi/templates/*
/usr/share/heketi/templates/deploy-heketi-template.yaml:          image: rhgs3/rhgs-volmanager-rhel7:3.3.0-362
/usr/share/heketi/templates/glusterblock-provisioner.yaml:          image: rhgs3/rhgs-gluster-block-prov-rhel7:3.3.0-362
/usr/share/heketi/templates/glusterfs-template.yaml:        - image: rhgs3/rhgs-server-rhel7:3.3.0-362
/usr/share/heketi/templates/gluster-s3-template.yaml:          image: rhgs3/rhgs-s3-server-rhel7:3.3.0-362
/usr/share/heketi/templates/heketi-template.yaml:          image: rhgs3/rhgs-volmanager-rhel7:3.3.0-362
```

Those images have been released already on [access](https://access.redhat.com/containers/#/search/rhgs3).

Then we can run a [playbook](../playbooks#prepare-cns-deploy-tool) to prepare cns-tool with inventory like this:

```
[masters]
ec2-54-218-80-58.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_private_key_file="/home/hongkliu/.ssh/id_rsa_perf"

[others]
ec2-54-186-95-29.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_private_key_file="/home/hongkliu/.ssh/id_rsa_perf"

[glusterfs]
ec2-54-191-66-43.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_private_key_file="/home/hongkliu/.ssh/id_rsa_perf"
ec2-54-218-60-199.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_private_key_file="/home/hongkliu/.ssh/id_rsa_perf"
ec2-34-223-226-135.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_private_key_file="/home/hongkliu/.ssh/id_rsa_perf"
```

```sh
$ ansible-playbook -i inv.file playbooks/cns_deploy.yml
```

Run cns-deploy (on master):

```sh
# oc new-project storage-project
# oadm policy add-scc-to-user privileged -z storage-project
# cns-deploy -n namespace -g topology.json -y
...
Deployment complete!

#  oc get pod -n storage-project
NAME                                  READY     STATUS    RESTARTS   AGE
glusterblock-provisioner-dc-1-hb9w2   1/1       Running   0          4m
glusterfs-j9qjp                       1/1       Running   0          6m
glusterfs-ld7nk                       1/1       Running   0          6m
glusterfs-whgvk                       1/1       Running   0          6m
heketi-1-nzvps                        1/1       Running   0          4m
```

Notice that there is new block provisioner pod <code>glusterblock-provisioner-dc-1-hb9w2</code>.

Create storage class for block volumes:

```sh
# oc get route -n storage-project 
NAME      HOST/PORT                                             PATH      SERVICES   PORT      TERMINATION   WILDCARD
heketi    heketi-storage-project.apps.1031-hye.qe.rhcloud.com             heketi     <all>                   None

# vi sc_glusterblock.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: glusterblock
provisioner: gluster.org/glusterblock
parameters:
  resturl: "http://heketi-storage-project.apps.1031-hye.qe.rhcloud.com"
  restuser: "admin"
  opmode: "heketi"
  hacount: "2"
  restauthenabled: "false"

# oc create -f sc_glusterblock.yaml
```

TODO: CANNOT create pvc yet!!!

## Debug
If something goes wrong, check

1) are services
systemctl status glusterd gluster-blockd tcmu-runner gluster-block-target

running inside cns pods

2) are ports open - per cns-deploy warning message

3) check does rpcbind runs

4) check are modules loaded

5) check http://post-office.corp.redhat.com/archives/rhs-containers/2017-September/msg00012.html



