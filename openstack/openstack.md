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


## Useful commands

image-id: qe-rhel-74-20180228; Fedora-Cloud-Base-27-1.6

[Cli: man](https://docs.openstack.org/python-openstackclient/latest/cli/man/openstack.html)

```sh
(osenv) [hongkliu@hongkliu oscli]$ openstack --os-cloud os10 server create --availability-zone nova --image qe-rhel-74-20170928 --flavor m1.medium --network openshift-qe-jenkins --security-group default --key-name libra --min 1 --max 1 qe-hongkliu-test-0929

(osenv) [hongkliu@hongkliu oscli]$ openstack --os-cloud os10 floating ip list
# # choose one whose "Fixed IP Address" is None
(osenv) [hongkliu@hongkliu oscli]$ openstack --os-cloud os10 server add floating ip qe-hongkliu-test-0929 10.8.241.68

(osenv) [hongkliu@hongkliu oscli]$ openstack --os-cloud os10 volume create --size 23 --type ceph qe-hongkliu-v1
VolumeLimitExceeded: Maximum number of volumes allowed (50) exceeded for quota 'volumes'. (HTTP 413) (Request-ID: req-bb897546-4346-424d-bb96-b152efc3944c)
```

TODO

* server add volume: https://docs.openstack.org/python-openstackclient/latest/cli/command-objects/server.html#server-add-volume
* create server with block devices: --block-device-mapping seems the right one, but also hard. https://docs.openstack.org/python-openstackclient/latest/cli/command-objects/server.html#server-create


