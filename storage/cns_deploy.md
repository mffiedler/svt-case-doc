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

Config this folder as a local yum repo. See the steps in [docker_version.md](../fix/docker_version.md)




1) 


install them on ocp nodes supposed to run cns pods.

These new packages will require new images, ( do : grep -ri rhgs /usr/share/heketi/templates/* ) and you will get what images these packages requires.

Further , to get these packages, ensure in /etc/sysconfig/docker there is

ADD_REGISTRY='--add-registry brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888 --add-registry registry.ops.openshift.com --add-registry registry.access.redhat.com'

INSECURE_REGISTRY='--insecure-registry registry.ops.openshift.com --insecure-registry brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888'


with packages in place, run cns-deploy as in past

# cns-deploy -n namespace -g topology.json


Ensure that modules cns-deploy says to load are loaded on *all* ocp nodes - including ones hosting cns pods


Also, ensure that ports 3260, 111, 24010 are open on all nodes, eg [1]

Make sure to run below on ocp nodes where will run cns pods

# systemctl add-wants multi-user rpcbind.service
# systemctl enable rpcbind
# systemctl start rpcbind

Run cns-deploy

# cns-deploy -n namespace -g topology.json

This will setup cns and it will be possible to create new block volumes, you will notice that there is new block provisioner pod.

an example of storage class for block volumes is

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: glusterblock
provisioner: gluster.org/glusterblock
parameters:
  resturl: "http://heketi-cnscluster.router.default.svc.cluster.local"
  restuser: "admin"
  opmode: "heketi"
  hacount: "2"
  restauthenabled: "false"


If something goes wrong, check

1) are services
systemctl status glusterd gluster-blockd tcmu-runner gluster-block-target

running inside cns pods

2) are ports open - per cns-deploy warning message

3) check does rpcbind runs

4) check are modules loaded

5) check http://post-office.corp.redhat.com/archives/rhs-containers/2017-September/msg00012.html



Also, write here or at rhs/cns mailing lists

Thank you

Kind regards,




[1]
A OS_FIREWALL_ALLOW -p udp -m state --state NEW -m udp --dport 4789 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 24007 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 24008 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m multiport --dports 49152:49251 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 3260 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 24006 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 111 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 24010 -j ACCEPT
