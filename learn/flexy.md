# Flexy (Internal)

Flexy is a [Jenkins job](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/Launch%20Environment%20Flexy/)
which generates OC cluster. It runs a ruby script on a Jenkins slave.

* [Mojo1](https://mojo.redhat.com/docs/DOC-1125835)
* [Mojo2](https://mojo.redhat.com/docs/DOC-1074220)


## Parameters and tasks in the ruby script

* [yaml config](http://git.app.eng.bos.redhat.com/git/openshift-misc.git/plain/v3-launch-templates/system-testing/aos-36/aws/vars.ose36-aws-svt.yaml) set up parameters for the ruby script.

* Tasks:
  * Apply for subdomain (TODO)
  * Host provisioning: based on the AMI specified by <code>${LAUNCHER_VARS}.image</code>
  * Installation: 2 playbooks.
 
## AMI
It is build by the playbooks in [svt/image_provisioner](https://github.com/openshift/svt/tree/master/image_provisioner). 

TODO: Jenkins job

## Starting from AMI (manual steps if Flexy is not available)

### Launch instances
Launch 4 instances of m4.xlarge type based on AMI eg, ocp-3.6.151-1-gold-auto.

### Get a subdomain
Get a subdomain from [Dynect subdomain create](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/Dynect%20subdomain%20create/253/console) using parameters *ip of router*, "openshift", "v3"

### Create inventory file and run playbook
Create <code>/tmp/1.file</code> and <code>/tmp/2.file</code> and modify the following value in <code>2.file</code>:

```sh
#openshift_master_default_subdomain_enable=true
#openshift_master_default_subdomain=0718-wo2.qe.rhcloud.com
```
TODO: [Error](https://paste.fedoraproject.org/paste/QOLK4aFrNEUfPz9caojfmg) occurred in the run of the 2nd playbook.
Only master node is up.

```sh
Message:  Unable to start service atomic-openshift-node: Job for atomic-openshift-node.service failed because the control process exited with error code. See "systemctl status atomic-openshift-node.service" and "journalctl -xe" for details.
```

### Ansible configuration (Optional)

1. edit /etc/ansible/ansible.cfg
     - set forks to 20 (for our standard 4 node clusters, does not matter, but helps for larger clusters)
     - uncomment the log path
2. Run the playbook with 

  ```sh
  ansible-inventory -vvv -i <inventory> <playbook>
  ```

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


### SSH to Jenkins slave

#### Get slave IP
Click on the output of Jenkins build.

### SSH

```sh
$ ssh -i ~/.ssh/libra.pem root@<slave_ip>
```
