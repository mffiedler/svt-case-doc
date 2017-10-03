# Create a Cluster Manually (Internal)

## AMI
We should use AMIs with name <code>ocp-\<version\>-gold-auto</code>.

It is build by the playbooks in [svt/image_provisioner](https://github.com/openshift/svt/tree/master/image_provisioner). 

Jenkins job: [SVT_Run_AWS_Image_provisioner_after_Puddle_Detection](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/System%20Verification%20Test/job/SVT_Run_AWS_Image_provisioner_after_Puddle_Detection/)

Check the new version ([Firefox setup](https://engineering.redhat.com/trac/Libra/wiki/Libra%20Repository)): [https://mirror.openshift.com/enterprise/all/3.6/latest/RH7-RHAOS-3.6/x86_64/os](https://mirror.openshift.com/enterprise/all/3.6/latest/RH7-RHAOS-3.6/x86_64/os).

## Starting from AMI

### Launch instances
Launch 4 instances of m4.xlarge type based on AMI eg, ocp-3.6.151-1-gold-auto using [aws-cli](ec2.md).

```sh
$ (awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-7b26c103 \
    --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.xlarge --key-name id_rsa_perf \
    --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 60}}]" \
    --query 'Instances[*].InstanceId' \
    --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-test\"}]}]"
```

The instance ids are in the return message. *Note that* <code>--image-id</code> is the AMI id and the value of <code>--image-id</code> is _the default group id_.

### Get a subdomain
Get a subdomain, eg, <code>0718-wo2.qe.rhcloud.com</code>, from [Dynect subdomain create](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/Dynect%20subdomain%20create/253/console) using parameters *ip of router*, "openshift", "v3"

If _Dynect_ is not available, one alternative is to use [xip.io](http://xip.io/). If the node, usually infra node(s), public ip where the router of the cluster runs is <code>54.214.91.134</code>, then use <code>openshift_master_default_subdomain=54.214.91.134.xip.io</code> in inventory:

### Ansible configuration (Optional)

1. edit /etc/ansible/ansible.cfg
     - set forks to 20 (for our standard 4 node clusters, does not matter, but helps for larger clusters)
     - uncomment the log path
2. Run the playbook with 

  ```sh
  ansible-inventory -vvv -i <inventory> <playbook>
  ```

### Create inventory file and run playbook
Run the 2 playbooks on master node. 

_Hint_: In the output of Jenkins build, search for *playbook*. The inventory file is printed out too. Copy the inventory file and remove <code>ansible_user=root ansible_ssh_user=root ansible_ssh_private_key_file="/home/slave1/workspace/Launch Environment Flexy/private/config/keys/id_rsa_perf"</code>.

1. aws_install_prep (optional if based on gold-AMI)

    ```sh
    # ansible-playbook -i /tmp/1.file aos-ansible/playbooks/aws_install_prep.yml
    ```

2. config

    Checking points before running the following playbook:

    * hostnames, variables on them
    * subdomain
    * aws keys

    ```sh
    # ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/byo/config.yml
    ```

## Scaleup cluster
TODO: Add [new nodes section] into <code>/tmp/2.file</code>

```sh
# ansible-playbook -i /tmp/3.file openshift-ansible/playbooks/byo/openshift-node/scaleup.yml 
```


## Create all-in-one cluster

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-6ca0ba15 --security-group-ids sg-5c5ace38 \
    --count 1 --instance-type m4.xlarge --key-name id_rsa_perf --subnet subnet-4879292d  \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 30}}]" \
    --query 'Instances[*].InstanceId'  \
    --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-all-in-one-test\"}]}]"
    
```

After create 1 node using _aws-cli_, modify <code>2.file</code> with additional checking points:

* router and docker-registry with <code>default</code> zone instead of infra.
* enable master node schedulable

```
[nodes]
...
openshift_registry_selector="region=primary,zone=default"
openshift_hosted_router_selector="region=primary,zone=default"
...
ec2-54-187-182-161.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_user=root openshift_public_hostname=ec2-54-187-182-161.us-west-2.compute.amazonaws.com openshift_node_labels="{'region': 'primary', 'zone': 'default'}" openshift_schedulable=true
...
```
Then run the 2nd playbook.
