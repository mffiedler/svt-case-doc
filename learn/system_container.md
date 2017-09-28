# System Container

## Doc

* [system-container@os](https://docs.openshift.com/container-platform/latest/install_config/install/advanced_install.html#advanced-install-configuring-system-containers)
* [system-container@acess](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/managing_containers/running_system_containers)
* [system-container@atomic-blog](http://www.projectatomic.io/blog/2016/09/intro-to-system-containers/)

## Existing system containers

* [etcd and flannel](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/managing_containers/running_system_containers)


## Openshift and system container

Using flexy to install openshift cluster on Atomic Host using system containers: [Here](https://github.com/hongkailiu/svt-case-doc/blob/master/learn/flexy.md#atomic-host).

Check the system container:

```sh
# atomic containers list --no-trunc 
   CONTAINER ID                        IMAGE                                                    COMMAND                                    CREATED          STATE      BACKEND    RUNTIME   
   etcd                                registry.access.redhat.com/rhel7/etcd                    /usr/bin/etcd-env.sh /usr/bin/etcd         2017-09-28 12:35 running    ostree     runc      
   atomic-openshift-master-api         registry.ops.openshift.com/openshift3/ose:v3.7.0         /usr/local/bin/system-container-wrapper.sh 2017-09-28 12:44 running    ostree     runc      
   atomic-openshift-master-controllers registry.ops.openshift.com/openshift3/ose:v3.7.0         /usr/local/bin/system-container-wrapper.sh 2017-09-28 12:44 running    ostree     runc      
   atomic-openshift-node               registry.ops.openshift.com/openshift3/node:v3.7.0        /usr/local/bin/system-container-wrapper.sh 2017-09-28 12:51 running    ostree     runc      
   openvswitch                         registry.ops.openshift.com/openshift3/openvswitch:v3.7.0 /usr/local/bin/system-container-wrapper.sh 2017-09-28 12:51 running    ostree     runc
```



## Useful links

1. [blog on ostree](https://samthursfield.wordpress.com/2014/01/16/the-fundamentals-of-ostree/)
