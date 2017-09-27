# Openshift-Ansible

* [src repo](https://github.com/openshift/openshift-ansible)

## Ways to use
Either clone the repo, and run the playbook defined in side. This is how our flexy works. Flexy always checks out the latest code of the repo.
Or use <code>openshift-ansible</code> command installed by rpm [built from the repo](https://github.com/openshift/openshift-ansible/blob/master/BUILD.md).

Here we focus on the rpm way.

## Reverse Engineering

On our gold AMIs, the openshift-ansible rpm is installed already:

```sh
# repoquery -i openshift-ansible

Name        : openshift-ansible
Version     : 3.7.0
Release     : 0.127.0.git.0.b9941e4.el7
Architecture: noarch
Size        : 42217
Packager    : Red Hat, Inc. <http://bugzilla.redhat.com/bugzilla>
Group       : Unspecified
URL         : https://github.com/openshift/openshift-ansible
Repository  : aos
Summary     : Openshift and Atomic Enterprise Ansible
Source      : openshift-ansible-3.7.0-0.127.0.git.0.b9941e4.el7.src.rpm
Description :
Openshift and Atomic Enterprise Ansible

This repo contains Ansible code and playbooks
for Openshift and Atomic Enterprise.

# #Actually more rpms are installed
# yum list installed openshift-ansible\*
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Installed Packages
openshift-ansible.noarch                                          3.7.0-0.126.4.git.0.3fc2b9b.el7                          @aos
openshift-ansible-callback-plugins.noarch                         3.7.0-0.126.4.git.0.3fc2b9b.el7                          @aos
openshift-ansible-docs.noarch                                     3.7.0-0.126.4.git.0.3fc2b9b.el7                          @aos
openshift-ansible-filter-plugins.noarch                           3.7.0-0.126.4.git.0.3fc2b9b.el7                          @aos
openshift-ansible-lookup-plugins.noarch                           3.7.0-0.126.4.git.0.3fc2b9b.el7                          @aos
openshift-ansible-playbooks.noarch                                3.7.0-0.126.4.git.0.3fc2b9b.el7                          @aos
openshift-ansible-roles.noarch                                    3.7.0-0.126.4.git.0.3fc2b9b.el7                          @aos
```

[get dependencies of openshift-ansible](https://superuser.com/questions/294662/how-to-get-list-of-dependencies-of-non-installed-rpm-package)

```sh
# repoquery --requires --resolve openshift-ansible
python-passlib-0:1.6.2-2.el7.noarch
java-1.8.0-openjdk-headless-1:1.8.0.131-3.b12.el7_3.i686
java-1.8.0-openjdk-headless-1:1.8.0.131-3.b12.el7_3.x86_64
python-0:2.7.5-34.el7.x86_64
libselinux-python-0:2.5-6.el7.x86_64
tar-2:1.26-31.el7.x86_64
python-six-0:1.3.0-4.el7.noarch
ansible-0:2.3.1.0-1.el7.noarch
httpd-tools-0:2.4.6-40.el7_2.4.x86_64
python2-passlib-0:1.6.5-1.el7.noarch
openshift-ansible-docs-0:3.7.0-0.127.0.git.0.b9941e4.el7.noarch
```


[list content of openshift-ansible-playbooks](https://stackoverflow.com/questions/104055/how-to-list-the-contents-of-a-package-using-yum)

```sh
# repoquery -l openshift-ansible-playbooks
...
/usr/share/ansible/openshift-ansible/playbooks/byo/config.yml
...
```

So the playbook we usually need to install the cluster comes with RPMs already.

## Manual installation: RPM way

Launch instances:

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-47669b3f     --security-group-ids sg-5c5ace38 --count 4 --instance-type m4.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-aaa-0927\"}]}]"
```

Check the version (optional):

```sh
# rpm -q openshift-ansible
openshift-ansible-3.7.0-0.126.4.git.0.3fc2b9b.el7.noarch
```

On master: Edit the inv. file: see [manual_cluster](manual_cluster.md) for details:

[Run the playbook](https://docs.openshift.com/container-platform/3.6/install_config/install/advanced_install.html#running-the-advanced-installation-rpm):

```sh
# ansible-playbook -i  /tmp/2.file /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml
```

The way I prefer to do Flexy:
1. generate inv. file
2. copy the inv. file to master
3. run the playbook from RPM with the copied inv. file

This way, flexy is still flexible to generate inv. file. Once it works, it will always work as long as AMI-based instances do not change. Moreover, we do not need to test all commits of the repo, only the released version from RPMs.
