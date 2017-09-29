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

(osenv) [hongkliu@hongkliu oscli]$ cat auth.sh
export OS_AUTH_URL=https//ci-rhos.centralci.eng.rdu2.redhat.com:35357/v2.0/
export OS_IDENTITY_API_VERSION=2
export OS_PROJECT_ID=e0fa85b6a06443959d2d3b497174bed6
#export OS_PROJECT_DOMAIN_NAME=<project-domain-name>
export OS_USERNAME=<username>
#export OS_USER_DOMAIN_NAME=<user-domain-name>
export OS_PASSWORD=<password>

(osenv) [hongkliu@hongkliu oscli]$ source auth.sh
# #need to fix this
(osenv) [hongkliu@hongkliu oscli]$ openstack server list
Failed to discover available identity versions when contacting https://ci-rhos.centralci.eng.rdu2.redhat.com:35357/v2.0/. Attempting to parse version from URL.
SSL exception connecting to https://ci-rhos.centralci.eng.rdu2.redhat.com:35357/v2.0/tokens: HTTPSConnectionPool(host='ci-rhos.centralci.eng.rdu2.redhat.com', port=35357): Max retries exceeded with url: /v2.0/tokens (Caused by SSLError(SSLError("bad handshake: Error([('SSL routines', 'ssl3_get_record', 'wrong version number')],)",),))
```


https://docs.openstack.org/python-openstackclient/latest/#getting-started
