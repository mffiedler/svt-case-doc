# OpenStack
ssh key: libra.pem


## [Install cli](https://pypi.python.org/pypi/python-openstackclient)

```sh
[hongkliu@hongkliu oscli]$ pwd
/home/hongkliu/tool/oscli
[hongkliu@hongkliu oscli]$ virtualenv osenv
[hongkliu@hongkliu oscli]$ source osenv/bin/activate
(osenv) [hongkliu@hongkliu oscli]$ sudo yum install -y python-devel
(osenv) [hongkliu@hongkliu oscli]$ pip install python-openstackclient
(osenv) [hongkliu@hongkliu oscli]$ openstack --version
openstack 3.12.0

```

## [Configure cli](https://docs.openstack.org/python-openstackclient/latest/configuration/index.html)

```sh
(osenv) [hongkliu@hongkliu oscli]$ cat ~/.config/openstack/clouds.yaml 
clouds:
  os10:
    auth:
      auth_url: https://ci-rhos.centralci.eng.rdu2.redhat.com:13000/v2.0/
      project_name: openshift-qe-jenkins
      username: openshift-qe-jenkins
      password: <secret>

# # we should see the instances there
(osenv) [hongkliu@hongkliu oscli]$ openstack --os-cloud os10 server list
```


## [Cli: man](https://docs.openstack.org/python-openstackclient/latest/cli/man/openstack.html)


