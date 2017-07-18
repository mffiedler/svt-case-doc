# Flexy (Internal)

Flexy is a [Jenkins job](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/Launch%20Environment%20Flexy/)
which generates OC cluster. It runs a ruby script on a Jenkins slave.

* [Mojo1](https://mojo.redhat.com/docs/DOC-1125835)
* [Mojo2](https://mojo.redhat.com/docs/DOC-1074220)


## Parameters and tasks in the ruby script

* [yaml config](http://git.app.eng.bos.redhat.com/git/openshift-misc.git/plain/v3-launch-templates/system-testing/aos-36/aws/vars.ose36-aws-svt.yaml) set up parameters for the ruby script.

* Tasks:
  * Apply for sub-domain (TODO)
  * Host provisioning: based on the AMI specified by <code><code>
  * Installation: 2 playbooks.
 
## AMI
It is build by the playbooks in [svt/image_provisioner](https://github.com/openshift/svt/tree/master/image_provisioner). 

TODO: Jenkins job

## Starting from AMI
Launch 4 instances of m4.xlarge type based on AMI eg, ocp-3.6.151-1-gold-auto.




## Debugging

### Flexy failed to run playbooks

We can rerun the 2 playbooks on master node. In the output of Jenkins build, search for *playbook*. The inventory file is printed out too.
Copy the inventory file and remove
<code>ansible_user=root ansible_ssh_user=root ansible_ssh_private_key_file="/home/slave1/workspace/Launch Environment Flexy/private/config/keys/id_rsa_perf"</code>

1. aws_install_prep

```
["ansible-playbook", "-v", "-i", "/home/slave1/workspace/Launch Environment Flexy/workdir/OS1-install36-1-0/inventory.aos-ansible", "/home/slave1/workspace/Launch Environment Flexy/private-aos-ansible/playbooks/aws_install_prep.yml"]
```

```sh
# ansible-playbook -i /tmp/1.file aos-ansible/playbooks/aws_install_prep.yml
```

2. config

```
["ansible-playbook", "-v", "-i", "/home/slave1/workspace/Launch Environment Flexy/workdir/OS1-install36-1-0/inv.ose34-aws-svt", "/home/slave1/workspace/Launch Environment Flexy/private-openshift-ansible/playbooks/byo/config.yml"]
```

```sh
# ansible-playbook -i /tmp/1.file aos-ansible/playbooks/aws_install_prep.yml
```
