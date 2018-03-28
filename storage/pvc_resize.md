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
vi /etc/origin/master/master-config.yaml
admissionConfig:
  pluginConfig:
    PersistentVolumeClaimResize:
      configuration:
        apiVersion: v1
        kind: DefaultAdmissionConfig
        disable: false
    BuildDefaults:
...

# systemctl restart atomic-openshift-master-api atomic-openshift-master-controllers

### verify in journal
# journalctl -b -u atomic-openshift-master-* | grep -i resize
```

This may require on _each node_:
`feature gate` seems like a command line flag when running k8s. What should we do in the
context of openshift?

Inspired by [this example](https://blog.openshift.com/how-to-use-gpus-in-openshift-3-6-still-alpha/):

```sh
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


Modify the sc:

```sh
# oc edit sc glusterfs-storage
...
reclaimPolicy: Delete
allowVolumeExpansion: true

### Checking
# oc get sc glusterfs-storage -o yaml
```

Hit [bz 1531509](https://bugzilla.redhat.com/show_bug.cgi?id=1531509). Also see [bz 1531513](https://bugzilla.redhat.com/show_bug.cgi?id=1531513)
