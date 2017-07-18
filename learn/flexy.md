# Flexy (Internal)

Flexy is a [Jenkins job](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/Launch%20Environment%20Flexy/)
which generates OC cluster.

## Tasks

* Apply for sub-domain (TODO)
* Host provisioning (TODO)
* AMI
* Installation

## Debugging

### Flexy failed to run playbooks

We can rerun the 2 playbooks. In the output of Jenkins build, search for *playbook*. The inventory file is printed out too.
Copy the inventory file and remove
<code>ansible_user=root ansible_ssh_user=root ansible_ssh_private_key_file="/home/slave1/workspace/Launch Environment Flexy/private/config/keys/id_rsa_perf"</code>

1. aws_install_prep

```
["ansible-playbook", "-v", "-i", "/home/slave1/workspace/Launch Environment Flexy/workdir/OS1-install36-1-0/inventory.aos-ansible", "/home/slave1/workspace/Launch Environment Flexy/private-aos-ansible/playbooks/aws_install_prep.yml"]
```

2.

```
["ansible-playbook", "-v", "-i", "/home/slave1/workspace/Launch Environment Flexy/workdir/OS1-install36-1-0/inv.ose34-aws-svt", "/home/slave1/workspace/Launch Environment Flexy/private-openshift-ansible/playbooks/byo/config.yml"]
```
