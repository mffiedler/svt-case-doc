# PVC resize

## Doc

* [design@k8s](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/storage/grow-volume-size.md)
* [pvc_resize@rlease_note_39](https://docs.openshift.com/container-platform/3.9/release_notes/ocp_3_9_release_notes.html#ocp-39-pv-resize)
* [demo@humble's blog](https://www.humblec.com/glusterfs-dynamic-provisioner-online-resizing-of-glusterfs-pvs-in-kubernetes-v-1-8/)

## Configure

As requested [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#expanding-persistent-volumes-claims),
"Administrator can allow expanding persistent volume claims by setting `ExpandPersistentVolumes` feature gate to `true`.
Administrator should also enable `PersistentVolumeClaimResize` admission plugin to perform additional validations of volumes that can be resized."

So it seems it requires 2 things:

* set `ExpandPersistentVolumes` feature gate to `true`
* enable `PersistentVolumeClaimResize` admission plugin

Begin with the 2nd.

Inspired from example [here](https://docs.openshift.com/container-platform/3.9/architecture/additional_concepts/admission_controllers.html#admission-controllers-general-admission-rules):

```sh
### On all masters:
# vi /etc/origin/master/master-config.yaml
admissionConfig:
  pluginConfig:
    PersistentVolumeClaimResize:
      configuration:
        apiVersion: v1
        kind: DefaultAdmissionConfig
        disable: false
    BuildDefaults:
...
### The missing part in the first try:
kubernetesMasterConfig:
  ...
  apiServerArguments:
    feature-gates:
    - ExpandPersistentVolumes=true
  ...
  controllerArguments:
    feature-gates:
    - ExpandPersistentVolumes=true

# systemctl restart atomic-openshift-master-api atomic-openshift-master-controllers

### verify in journal
# journalctl -b -u atomic-openshift-master-* | grep -i resize
```

`feature gate` seems like a command line flag when running k8s. What should we do in the
context of openshift?

Inspired by [this example](https://blog.openshift.com/how-to-use-gpus-in-openshift-3-6-still-alpha/):

```sh
### On all nodes:
# vi /etc/origin/node/node-config.yaml
kubeletArguments:
...
  feature-gates:
  - ExpandPersistentVolumes=true
...

# systemctl restart atomic-openshift-node

### verify in journal
# journalctl -b -u atomic-openshift-node.service | grep gates
```

This should be controlled by the following [variable in ansible-playbook](https://docs.openshift.com/enterprise/3.2/install_config/install/advanced_install.html):

```
openshift_node_kubelet_args='{"pods-per-core": ["0"], "max-pods": ["510"], "image-gc-high-threshold": ["80"], "image-gc-low-threshold": ["70"], "feature-gates": ["ExpandPersistentVolumes=true"]}'
```


Create the sc:

```sh
# oc get sc glusterfs-storage -o yaml > glusterfs-storage-exp.yaml
# vi glusterfs-storage-exp.yaml
...
  name: glusterfs-storage-exp
...
reclaimPolicy: Delete
allowVolumeExpansion: true

# oc create -f ./glusterfs-storage-exp.yaml 
### Checking if the new entry "allowVolumeExpansion" is saved.
# oc get sc glusterfs-storage-exp -o yaml
allowVolumeExpansion: true
...
```

Check [bz 1531509](https://bugzilla.redhat.com/show_bug.cgi?id=1531509) for details of configuration. Also see [bz 1531513](https://bugzilla.redhat.com/show_bug.cgi?id=1531513)

Observations:
* When k8s says enable some feature gate, we need to enable it in 3 places in the context of openshift: master-api, master-controllers, node. In openshift-ansibles, there are controlled by `openshift.master.api_server_args`, `openshift.master.controller_args`, and `openshift_node_kubelet_args`.
* When openshift says enable some plugin in admission config, it means changes in the setting of master config as described above. There is no variable yet in openshift-ansible to control this. Check via `grep -irn "podpreset" .`  in openshift-ansible how it is done for other plugins.

