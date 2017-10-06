# Fedora

## Launch a Fedora 26 instance on AWS

Use command [here](https://github.com/hongkailiu/svt-case-doc/blob/master/ec2/ec2.md#fedora-26).

## Install docker


## Run byo playbook

Found when installing logging stack: Need <code>libselinux-python</code> and <code>keytool</code>.


```sh
[fedora@ip-172-31-33-174 ~]$ sudo dnf install libselinux-python
# #keytool comes with jdk
[fedora@ip-172-31-33-174 ~]$ sudo rpm -Uvh jdk-8u144-linux-x64.rpm 
# #checking keytool
[fedora@ip-172-31-33-174 ~]$ whereis keytool
keytool: /usr/bin/keytool /usr/share/man/man1/keytool.1
```
