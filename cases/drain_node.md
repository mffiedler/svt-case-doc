

# Drain Node Test
Cluster:

| role  |  number  |
|---|---|
| lb (master) | 1 |
| master-etcd   |  1 |
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

Disable one of the computing node <code>node2</code>.

Create pods with PVCs. 1 project, 249 templates:

```sh
# cd svt/openshift_scalability
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

Drain node <code>node1</code>.
