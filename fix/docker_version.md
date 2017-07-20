# Docker Version

## Check the current docker version

```sh
# docker version
Client:
 Version:         1.12.6
 API version:     1.24
 Package version: docker-1.12.6-40.1.gitf55a118.el7.x86_64
 Go version:      go1.8.3
 Git commit:      f55a118/1.12.6
 Built:           Mon Jul  3 14:02:53 2017
 OS/Arch:         linux/amd64

Server:
 Version:         1.12.6
 API version:     1.24
 Package version: docker-1.12.6-40.1.gitf55a118.el7.x86_64
 Go version:      go1.8.3
 Git commit:      f55a118/1.12.6
 Built:           Mon Jul  3 14:02:53 2017
 OS/Arch:         linux/amd64
```

## Update docker

Download all the rpms from [brew](http://you_should_know.com) to <code>~/local_rpm_repo</code> folder on remote host.

```sh
# cd local_rpm_repo/
# yum install -y createrepo
# createrepo .
# cat /etc/yum.repos.d/local.repo 
[localrepo]
name=Local Repo
baseurl=file:///root/local_rpm_repo
failovermethod=priority
enabled=1
gpgcheck=0
protect=1

# yum list docker
# yum update docker
# docker version
# systemctl status atomic-openshift-master
# systemctl restart atomic-openshift-master
# systemctl restart atomic-openshift-node
# systemctl status atomic-openshift-master
```
