# Mike's way of getting 3.10 OCP

Use AMI:

```sh
$ aws ec2 run-instances --image-id ami-c1ed81b9    --security-group-ids sg-5c5ace38 --count 3 --instance-type m4.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 60, \"VolumeType\": \"gp2\"}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-310\"}, {\"Key\":\"KubernetesCluster\",\"Value\":\"hongkliu\"}]}]"
```

Use Jianlin's openshift-ansible repo on `openshift-ansible-3.10.0-0.22.0-new_image` branch:

```sh
$ mkdir jianlin
$ cd jianlin/
$ git clone https://github.com/jianlinliu/openshift-ansible.git
$ git checkout openshift-ansible-3.10.0-0.22.0-new_image

$ git branch
  master
* openshift-ansible-3.10.0-0.22.0-new_image

$ cd
```

Modify Mike's magic inventory file `/tmp/2.file`.

Using the private dns of hosts, instead of the public ones, except `openshift_master_cluster_public_hostname`.


```sh
$ ansible-playbook -i /tmp/2.file jianlin/openshift-ansible/playbooks/prerequisites.yml
$ ansible-playbook -i /tmp/2.file jianlin/openshift-ansible/playbooks/deploy_cluster.yml
```

If failed on the following tasks, then reboot master and rerun the playbook.

```
TASK [openshift_control_plane : Verify that the control plane is running] *************************************************
FAILED - RETRYING: Verify that the control plane is running (60 retries left).
```

If nodes are `NotReady` after a successful playbook run, then reboot them too.


```sh
# oc get node
NAME                                          STATUS    ROLES           AGE       VERSION
ip-172-31-10-207.us-west-2.compute.internal   Ready     master          35m       v1.10.0+b81c8f8
ip-172-31-15-199.us-west-2.compute.internal   Ready     compute,infra   31m       v1.10.0+b81c8f8
ip-172-31-27-110.us-west-2.compute.internal   Ready     compute         31m       v1.10.0+b81c8f8

# oc get pod --all-namespaces -o wide
NAMESPACE                           NAME                                                             READY     STATUS    RESTARTS   AGE       IP              NODE
default                             docker-registry-1-28vd9                                          1/1       Running   0          41m       10.129.0.4      ip-172-31-15-199.us-west-2.compute.internal
default                             registry-console-1-kvt8x                                         1/1       Running   0          46m       10.128.0.3      ip-172-31-10-207.us-west-2.compute.internal
default                             router-1-99qt7                                                   1/1       Running   0          42m       172.31.15.199   ip-172-31-15-199.us-west-2.compute.internal
kube-service-catalog                apiserver-flt9g                                                  1/1       Running   0          45m       10.128.0.5      ip-172-31-10-207.us-west-2.compute.internal
kube-service-catalog                controller-manager-6z7k7                                         1/1       Running   0          45m       10.128.0.6      ip-172-31-10-207.us-west-2.compute.internal
kube-system                         master-api-ip-172-31-10-207.us-west-2.compute.internal           1/1       Running   0          50m       172.31.10.207   ip-172-31-10-207.us-west-2.compute.internal
kube-system                         master-controllers-ip-172-31-10-207.us-west-2.compute.internal   1/1       Running   0          50m       172.31.10.207   ip-172-31-10-207.us-west-2.compute.internal
kube-system                         master-etcd-ip-172-31-10-207.us-west-2.compute.internal          1/1       Running   0          50m       172.31.10.207   ip-172-31-10-207.us-west-2.compute.internal
openshift-ansible-service-broker    asb-1-6w7l8                                                      1/1       Running   1          42m       10.130.0.3      ip-172-31-27-110.us-west-2.compute.internal
openshift-metrics                   prometheus-0                                                     6/6       Running   0          45m       10.129.0.5      ip-172-31-15-199.us-west-2.compute.internal
openshift-metrics                   prometheus-node-exporter-2qk74                                   1/1       Running   0          45m       172.31.15.199   ip-172-31-15-199.us-west-2.compute.internal
openshift-metrics                   prometheus-node-exporter-4955z                                   1/1       Running   0          45m       172.31.10.207   ip-172-31-10-207.us-west-2.compute.internal
openshift-metrics                   prometheus-node-exporter-g7k4d                                   1/1       Running   0          45m       172.31.27.110   ip-172-31-27-110.us-west-2.compute.internal
openshift-node                      sync-8fgr2                                                       1/1       Running   1          48m       172.31.27.110   ip-172-31-27-110.us-west-2.compute.internal
openshift-node                      sync-cqls7                                                       1/1       Running   1          48m       172.31.15.199   ip-172-31-15-199.us-west-2.compute.internal
openshift-node                      sync-p6jgh                                                       1/1       Running   1          49m       172.31.10.207   ip-172-31-10-207.us-west-2.compute.internal
openshift-sdn                       ovs-2j2v5                                                        1/1       Running   0          48m       172.31.27.110   ip-172-31-27-110.us-west-2.compute.internal
openshift-sdn                       ovs-gm8wf                                                        1/1       Running   0          48m       172.31.10.207   ip-172-31-10-207.us-west-2.compute.internal
openshift-sdn                       ovs-zlkdm                                                        1/1       Running   0          48m       172.31.15.199   ip-172-31-15-199.us-west-2.compute.internal
openshift-sdn                       sdn-97fcw                                                        1/1       Running   0          48m       172.31.15.199   ip-172-31-15-199.us-west-2.compute.internal
openshift-sdn                       sdn-g7z2l                                                        1/1       Running   0          48m       172.31.10.207   ip-172-31-10-207.us-west-2.compute.internal
openshift-sdn                       sdn-m4l2b                                                        1/1       Running   0          48m       172.31.27.110   ip-172-31-27-110.us-west-2.compute.internal
openshift-template-service-broker   apiserver-hxnvj                                                  1/1       Running   0          44m       10.128.0.7      ip-172-31-10-207.us-west-2.compute.internal
openshift-web-console               webconsole-888ff56b6-8wnc6                                       1/1       Running   0          46m       10.128.0.4      ip-172-31-10-207.us-west-2.compute.internal

```

Verify the object kind in Xiaoli's and Clayton's email:

* The control plane components (etcd, apiserver, and controllers) are now run as [static pods](https://kubernetes.io/docs/tasks/administer-cluster/static-pod/) by the Kubelet on the masters
```sh
# ps -ef | grep manifest
...--pod-manifest-path=/etc/origin/node/pods...
# ll /etc/origin/node/pods
total 12
-rw-------. 1 root root 1415 Apr 18 19:09 apiserver.yaml
-rw-------. 1 root root 1189 Apr 18 19:09 controller.yaml
-rw-------. 1 root root  856 Apr 18 19:08 etcd.yaml

# oc project kube-system
# oc get pod -o wide
NAME                                                             READY     STATUS    RESTARTS   AGE       IP              NODE
master-api-ip-172-31-10-207.us-west-2.compute.internal           1/1       Running   0          1h        172.31.10.207   ip-172-31-10-207.us-west-2.compute.internal
master-controllers-ip-172-31-10-207.us-west-2.compute.internal   1/1       Running   0          1h        172.31.10.207   ip-172-31-10-207.us-west-2.compute.internal
master-etcd-ip-172-31-10-207.us-west-2.compute.internal          1/1       Running   0          1h        172.31.10.207   ip-172-31-10-207.us-west-2.compute.internal

```

* Node bootstrapping (controlled by the inventory variable openshift_node_bootstrap) defaults to True instead of False, which means nodes will pull their configuration and client and server certificates from the master.

```sh
# oc project openshift-node
# oc get all
NAME             READY     STATUS    RESTARTS   AGE
pod/sync-8fgr2   1/1       Running   1          1h
pod/sync-cqls7   1/1       Running   1          1h
pod/sync-p6jgh   1/1       Running   1          1h

NAME                  DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/sync   3         3         3         3            3           <none>          1h

NAME                                  DOCKER REPO                                            TAGS      UPDATED
imagestream.image.openshift.io/node   docker-registry.default.svc:5000/openshift-node/node   v3.10     About an hour ago

```

* openshift-sdn and openvswitch, if enabled, will be run in a daemonset.

```sh
# oc project openshift-sdn
# oc get all
NAME            READY     STATUS    RESTARTS   AGE
pod/ovs-2j2v5   1/1       Running   0          1h
pod/ovs-gm8wf   1/1       Running   0          1h
pod/ovs-zlkdm   1/1       Running   0          1h
pod/sdn-97fcw   1/1       Running   0          1h
pod/sdn-g7z2l   1/1       Running   0          1h
pod/sdn-m4l2b   1/1       Running   0          1h

NAME                 DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/ovs   3         3         3         3            3           <none>          1h
daemonset.apps/sdn   3         3         3         3            3           <none>          1h

NAME                                  DOCKER REPO                                           TAGS      UPDATED
imagestream.image.openshift.io/node   docker-registry.default.svc:5000/openshift-sdn/node   v3.10     About an hour ago
```

* how to restart the control plane components and where to get their logs

```sh
### Note that there is no /usr/local/bin/master-exec
### but I think that we can always do oc-exec
# ll /usr/local/bin/master-*
-r-x------. 1 root root 1112 Apr 18 19:09 /usr/local/bin/master-logs
-r-x------. 1 root root  756 Apr 18 19:09 /usr/local/bin/master-restart
```

```sh
# systemctl list-units | grep atomic
atomic-openshift-node.service
```

** restart

```sh
### This one seems not working
# /usr/local/bin/master-restart api
### Or,
# oc delete pod -n kube-system master-api-ip-172-31-10-207.us-west-2.compute.internal
```

** logs

```sh
# /usr/local/bin/master-logs api api
### Or,
# oc logs -f -n kube-system master-api-ip-172-31-10-207.us-west-2.compute.internal
```

