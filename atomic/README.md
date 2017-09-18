# Project Atomic

## Doc

* [project-atomic](http://www.projectatomic.io)
* [atomic@github](https://github.com/projectatomic)
* [flannel](https://github.com/coreos/flannel)

## Launch an instance

AMI provisioner also produces atomic images and we can [launch via aws-cli](https://github.com/hongkailiu/svt-case-doc/blob/master/ec2/ec2.md#atomic-host),
or get AMIs on [fedora.org](https://getfedora.org/en/atomic/download/).



```sh
# cat /etc/*release
NAME="Red Hat Enterprise Linux Atomic Host"
VERSION="7.4.0"
...

# lsblk 
NAME                          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda                          202:0    0   50G  0 disk 
├─xvda1                       202:1    0  300M  0 part /boot
└─xvda2                       202:2    0 49.7G  0 part 
  ├─atomicos-root             253:0    0 19.8G  0 lvm  /sysroot
  └─atomicos-docker--root--lv 253:1    0   30G  0 lvm  /sysroot/ostree/deploy/rhel-atomic-host/var/lib/docker
```


## Tools
Docker, k8s and etcd are installed out of the box.

```sh
# docker info
...
Server Version: 1.12.6
Storage Driver: overlay2
 Backing Filesystem: xfs
Logging Driver: journald
...

# kubectl --version
Kubernetes v1.5.2

# etcd --version
etcd Version: 3.1.9
Git SHA: 0f4a535
Go Version: go1.8.3
Go OS/Arch: linux/amd64
...

```

## Configure K8S
TODO

## Tools: TODO

* [cri-o](cri_o.md)
* [buildah](buildah.md)
