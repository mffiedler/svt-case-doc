# Project Atomic

## Doc

* [project-atomic](http://www.projectatomic.io)
* [atomic@github](https://github.com/projectatomic)

## Launch an instance

AMI provisioner also produces atomic images and we can [launch via aws-cli](https://github.com/hongkailiu/svt-case-doc/blob/master/ec2/ec2.md#atomic-host).

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
