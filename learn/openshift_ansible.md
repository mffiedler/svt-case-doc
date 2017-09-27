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

```

[Get repo providing openshift-ansible](https://stackoverflow.com/questions/635869/can-yum-tell-me-which-of-my-repositories-provide-a-particular-package)

```sh
# yum list openshift-ansible
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Installed Packages
openshift-ansible.noarch                                  3.7.0-0.126.4.git.0.3fc2b9b.el7                                  @aos
Available Packages
openshift-ansible.noarch                                  3.7.0-0.127.0.git.0.b9941e4.el7                                  aos 
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


[list content of openshift-ansible](https://stackoverflow.com/questions/104055/how-to-list-the-contents-of-a-package-using-yum)

```sh
# repoquery -l openshift-ansible
/usr/share/ansible/openshift-ansible
/usr/share/ansible/openshift-ansible/library
/usr/share/ansible/openshift-ansible/library/kubeclient_ca.py
/usr/share/ansible/openshift-ansible/library/kubeclient_ca.pyc
/usr/share/ansible/openshift-ansible/library/kubeclient_ca.pyo
/usr/share/ansible/openshift-ansible/library/modify_yaml.py
/usr/share/ansible/openshift-ansible/library/modify_yaml.pyc
/usr/share/ansible/openshift-ansible/library/modify_yaml.pyo
/usr/share/ansible/openshift-ansible/library/rpm_q.py
/usr/share/ansible/openshift-ansible/library/rpm_q.pyc
/usr/share/ansible/openshift-ansible/library/rpm_q.pyo
/usr/share/ansible/openshift-ansible/playbooks/common/openshift-master/library.rpmmoved
/usr/share/doc/openshift-ansible-3.7.0
/usr/share/doc/openshift-ansible-3.7.0/README.md
/usr/share/doc/openshift-ansible-3.7.0/README_CONTAINERIZED_INSTALLATION.md
/usr/share/doc/openshift-ansible-3.7.0/README_CONTAINER_IMAGE.md
/usr/share/licenses/openshift-ansible-3.7.0
/usr/share/licenses/openshift-ansible-3.7.0/LICENSE
```
