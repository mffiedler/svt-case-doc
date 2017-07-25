# Create a Cluster Manually (Internal)

## AMI
It is build by the playbooks in [svt/image_provisioner](https://github.com/openshift/svt/tree/master/image_provisioner). 

Jenkins job: [SVT_Run_AWS_Image_provisioner_after_Puddle_Detection](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/System%20Verification%20Test/job/SVT_Run_AWS_Image_provisioner_after_Puddle_Detection/)

Check the new version ([Firefox setup](https://engineering.redhat.com/trac/Libra/wiki/Libra%20Repository)): [https://mirror.openshift.com/enterprise/all/3.6/latest/RH7-RHAOS-3.6/x86_64/os](https://mirror.openshift.com/enterprise/all/3.6/latest/RH7-RHAOS-3.6/x86_64/os).

## Starting from AMI

### Launch instances
Launch 4 instances of m4.xlarge type based on AMI eg, ocp-3.6.151-1-gold-auto using [aws-cli](ec2.md).

```sh
$ (awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-f2d3cd8b --security-group-ids sg-5c5ace38 --count 4 --instance-type m4.xlarge --key-name id_rsa_perf --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 60}}]"
```

The instance ids are in the return message. *Note that* <code>--image-id</code> is the AMI id and the value of <code>--image-id</code> is _the default group id_.

### Get a subdomain
Get a subdomain from [Dynect subdomain create](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/Dynect%20subdomain%20create/253/console) using parameters *ip of router*, "openshift", "v3"

### Ansible configuration (Optional)

1. edit /etc/ansible/ansible.cfg
     - set forks to 20 (for our standard 4 node clusters, does not matter, but helps for larger clusters)
     - uncomment the log path
2. Run the playbook with 

  ```sh
  ansible-inventory -vvv -i <inventory> <playbook>
  ```

### Create inventory file and run playbook
Create <code>/tmp/1.file</code> and <code>/tmp/2.file</code> and modify the following value in <code>2.file</code>:

```sh
#openshift_master_default_subdomain_enable=true
#openshift_master_default_subdomain=0718-wo2.qe.rhcloud.com
```

The commands to run the playbooks are [here](flexy.md).
