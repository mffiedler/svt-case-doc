

# Drain Node Test
Cluster:

| role  |  number  |
|---|---|
| lb (master) | 1 |
| master-etcd   |  2 |
| infra  | 1  |
| computing-nodes  | 2  |

## Config master

```sh
# vi /etc/sysconfig/atomic-openshift-master
...
KUBE_MAX_PD_VOLS=260
# systemctl daemon-reload
# systemctl restart atomic-openshift-master.service
# #or if the cluster is HA, do this on all masters:
# vi /etc/sysconfig/atomic-openshift-master-controllers
...
KUBE_MAX_PD_VOLS=260
# systemctl daemon-reload
# systemctl restart atomic-openshift-master-controllers.service
#
```

## Run test

Move _reg-console_ pod to infra-node.

```sh
# oc patch -n default deploymentconfigs/registry-console --patch '{"spec": {"template": {"spec": {"nodeSelector": {"region": "infra"}}}}}'
# oc patch -n openshift-ansible-service-broker deploymentconfigs/asb-etcd --patch '{"spec": {"template": {"spec": {"nodeSelector": {"region": "infra"}}}}}'
```

Disable one of the computing node <code>node2</code>.

```sh
# oadm manage-node $node2_name --schedulable=false
```

Create pods with PVCs. 1 project, 249 templates:

```sh
# cd svt/openshift_scalability
# curl -o ./content/fio/fio-template1.json https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/fio-template1.json
# vi content/fio/fio-parameters.yaml
...
        file: ./content/fio/fio-template1.json
        parameters:
          - STORAGE_CLASS: "gp2" # this is name of storage class to use
          - STORAGE_SIZE: "1Gi" # this is size of PVC mounted inside pod
          - MOUNT_PATH: "/mnt/pvcmount"
          - DOCKER_IMAGE: "gcr.io/google_containers/pause-amd64:3.0"
...

# python -u cluster-loader.py -v -f content/fio/fio-parameters.yaml
```

Enable the disabled computing node <code>node2</code>.

```sh
# oadm manage-node $node2_name --schedulable=true
```

Drain node <code>node1</code>.

```sh
# oadm drain $node1_name
```
