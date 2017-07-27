# Flexy (Internal)

Flexy is a [Jenkins job](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/Launch%20Environment%20Flexy/)
which generates OC cluster. It runs a ruby script on a Jenkins slave.

* [Mojo1](https://mojo.redhat.com/docs/DOC-1125835)
* [Mojo2](https://mojo.redhat.com/docs/DOC-1074220)


## Parameters and tasks in the ruby script

* [yaml config](http://git.app.eng.bos.redhat.com/git/openshift-misc.git/plain/v3-launch-templates/system-testing/aos-36/aws/vars.ose36-aws-svt.yaml) set up parameters for the ruby script.

* Tasks:
  * Apply for subdomain
  * Host provisioning: based on the AMI specified by <code>${LAUNCHER_VARS}.image</code>
  * Installation: 2 playbooks.

Follow the [steps](manual_cluster.md) to create a cluster manually if flexy is not available.

## Debugging for flexy

### Flexy failed to run playbooks

We can rerun the 2 playbooks on master node. In the output of Jenkins build, search for *playbook*. The inventory file is printed out too.
Copy the inventory file and remove
<code>ansible_user=root ansible_ssh_user=root ansible_ssh_private_key_file="/home/slave1/workspace/Launch Environment Flexy/private/config/keys/id_rsa_perf"</code>

1. aws_install_prep (optional if based on gold-AMI)

```
["ansible-playbook", "-v", "-i", "/home/slave1/workspace/Launch Environment Flexy/workdir/OS1-install36-1-0/inventory.aos-ansible", "/home/slave1/workspace/Launch Environment Flexy/private-aos-ansible/playbooks/aws_install_prep.yml"]
```

```sh
# ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/byo/config.yml
```

2. config

```
["ansible-playbook", "-v", "-i", "/home/slave1/workspace/Launch Environment Flexy/workdir/OS1-install36-1-0/inv.ose34-aws-svt", "/home/slave1/workspace/Launch Environment Flexy/private-openshift-ansible/playbooks/byo/config.yml"]
```

```sh
# ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/byo/config.yml
```

### Failed on some ansible task

Try to search it in [bugzilla](bugzalla.md)


### SSH to Jenkins slave

#### Get slave IP
Click on the output of Jenkins build.

#### SSH

```sh
$ ssh -i ~/.ssh/libra.pem root@<slave_ip>
```

## IOPS volumes for instances

<code>${CUCUSHIFT_CONFIG}</code>

```   ...
      instance_type: m4.xlarge
      block_device_mappings:
      - device_name: /dev/sdb
        ebs:
          volume_size: 80
          volume_type: io1
          iops: 2400
```

## Scaleup cluster
TODO: Add [new nodes section] into <code>/tmp/2.file</code>

```sh
# ansible-playbook -i /tmp/3.file openshift-ansible/playbooks/byo/openshift-node/scaleup.yml 
```


## Setup before/after tasks in Flexy
TODO
