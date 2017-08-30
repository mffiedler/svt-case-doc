# Storage Test with Manual Steps

## Prepare env
Build/Pull on docker image: Optional.

On a compute node:

The image has been built and pushed to docker.io:

```sh
# #Optional
# docker pull docker.io/hongkailiu/centosfio:3.6.172.0.0
```

Create scc on master:

```sh
# oc create -f svt/storage/content/fio-scc.json
# oc new-project aaa
```
* Scp _id_rsa.pub_ to _/root/.ssh/_.
* Modify _image_, _hostPath_, and _nodeSelector_ in _content/fio-pod-pv.json_.






