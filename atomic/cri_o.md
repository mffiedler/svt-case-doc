# CRI-O

## Doc

* [cri-o.io](http://cri-o.io/)
* [oci](https://www.opencontainers.org/)
* [oci-o](https://github.com/kubernetes-incubator/cri-o)

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
```
