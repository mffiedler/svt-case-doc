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

# oc get pod --all-namespaces
NAMESPACE                           NAME                                                             READY     STATUS    RESTARTS   AGE
default                             docker-registry-1-28vd9                                          1/1       Running   0          25m
default                             registry-console-1-kvt8x                                         1/1       Running   0          30m
default                             router-1-99qt7                                                   1/1       Running   0          25m
kube-service-catalog                apiserver-flt9g                                                  1/1       Running   0          28m
kube-service-catalog                controller-manager-6z7k7                                         1/1       Running   0          28m
kube-system                         master-api-ip-172-31-10-207.us-west-2.compute.internal           1/1       Running   0          34m
kube-system                         master-controllers-ip-172-31-10-207.us-west-2.compute.internal   1/1       Running   0          34m
kube-system                         master-etcd-ip-172-31-10-207.us-west-2.compute.internal          1/1       Running   0          33m
openshift-ansible-service-broker    asb-1-6w7l8                                                      1/1       Running   1          25m
openshift-metrics                   prometheus-0                                                     6/6       Running   0          29m
openshift-metrics                   prometheus-node-exporter-2qk74                                   1/1       Running   0          29m
openshift-metrics                   prometheus-node-exporter-4955z                                   1/1       Running   0          29m
openshift-metrics                   prometheus-node-exporter-g7k4d                                   1/1       Running   0          29m
openshift-node                      sync-8fgr2                                                       1/1       Running   1          31m
openshift-node                      sync-cqls7                                                       1/1       Running   1          31m
openshift-node                      sync-p6jgh                                                       1/1       Running   1          32m
openshift-sdn                       ovs-2j2v5                                                        1/1       Running   0          31m
openshift-sdn                       ovs-gm8wf                                                        1/1       Running   0          32m
openshift-sdn                       ovs-zlkdm                                                        1/1       Running   0          31m
openshift-sdn                       sdn-97fcw                                                        1/1       Running   0          31m
openshift-sdn                       sdn-g7z2l                                                        1/1       Running   0          32m
openshift-sdn                       sdn-m4l2b                                                        1/1       Running   0          31m
openshift-template-service-broker   apiserver-hxnvj                                                  1/1       Running   0          28m
openshift-web-console               webconsole-888ff56b6-8wnc6                                       1/1       Running   0          30m

```