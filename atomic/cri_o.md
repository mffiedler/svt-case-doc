# CRI-O

## Doc

* [cri-o.io](http://cri-o.io/)
* [oci](https://www.opencontainers.org/)
* [cri-o](https://github.com/kubernetes-incubator/cri-o), [cli: docker vs cri-o](https://github.com/kubernetes-incubator/cri-o/blob/master/transfer.md)

## Configure OpenShift node to use cri-o

### AH + cri-o

Installation: follow the steps in [flexy.md](../learn/flexy.md).

Checking:

```sh
# cat /etc/origin/node/node-config.yaml | grep "container-runtime:" -A5
  container-runtime:
  - remote
  container-runtime-endpoint:
  - /var/run/crio.sock
  image-service-endpoint:
  - /var/run/crio.sock

# atomic containers list -a --no-trunc | grep "cri-o"
   cri-o                               registry.ops.openshift.com/openshift3/cri-o:latest       /usr/bin/run.sh                            2017-10-03 18:49 running    ostree     runc
```

So cri-o runs as a system container.

TODO: no pods in default is running. BZ.

Check if docker knows any pods is running.

### RHEL + cri-o

```sh
### Both docker and cri-o are running on the system after installation
# systemctl status cri-o.service
# systemctl status docker.service
### Vikas: for now, "docker build" is still via docker.service
```

Proof of using cri-o

```sh
# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
# atomic containers list
   CONTAINER ID IMAGE                NAME       COMMAND    CREATED          STATE      BACKEND    RUNTIME   
   cri-o        registry.reg-aws.ope cri-o      /usr/bin/r 2018-02-07 15:08 running    ostree     /bin/runc 

### Checking node config
# grep -rin "crio" /etc/origin/node/node-config.yaml -B1
32-  container-runtime-endpoint:
33:  - /var/run/crio/crio.sock
34-  image-service-endpoint:
35:  - /var/run/crio/crio.sock
```
