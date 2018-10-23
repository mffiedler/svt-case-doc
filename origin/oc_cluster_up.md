# oc cluster up

doc: [cluster_up_down](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md)

## Test environment
Tested with Fedora 27: Install docker and oc-client

```sh
$ docker --version
Docker version 1.13.1, build 7f1fa5c-unsupported
$ curl -O -L https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
$ tar -xzf openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
$ mkdir bin
$ cd bin
$ ln -s ../openshift-origin-client-tools-v3.9.0-191fece-linux-64bit/oc oc
$ cd
$ oc version
oc v3.9.0+191fece
kubernetes v1.9.1+a0ce1bc657
features: Basic-Auth GSSAPI Kerberos SPNEGO
```

## cluster-up

```sh
$ oc cluster up
```

Hit the [issues/4191](https://github.com/openshift/origin/issues/4191):

```sh
$ sudo vi /etc/docker/daemon.json
{
  "insecure-registries" : ["172.30.0.0/16"]
}
$ sudo systemctl restart docker
```

```sh
$ docker ps --no-trunc
CONTAINER ID                                                       IMAGE                                                                                                                COMMAND                                                                                                                                                                                            CREATED             STATUS              PORTS               NAMES
754839ad69c3690c08ff1a3cd60ba81916927ebce6ae8355c381e3c2ed015672   docker.io/openshift/origin-docker-registry@sha256:1be053b8cc6b9569ec7dc56cb5287c561654b6767457e53121c89f35bab6cbc5   "/bin/sh -c '/usr/bin/dockerregistry ${REGISTRY_CONFIGURATION_PATH}'"                                                                                                                              4 minutes ago       Up 4 minutes                            k8s_registry_docker-registry-1-xzc9d_default_95172d65-39a7-11e8-897e-02e44597d37c_0
065278d7761a8c5f4818f8b7ff11c824640ce2a23cd7164b60b64a5455ede173   docker.io/openshift/origin-haproxy-router@sha256:804de86e46372684a452a28c922932a7ed023a2a32a935886fba9c7724351428    "/usr/bin/openshift-router"                                                                                                                                                                        4 minutes ago       Up 4 minutes                            k8s_router_router-1-6q8n5_default_93ce263d-39a7-11e8-897e-02e44597d37c_0
522e47e040d610658c3d042766b4056a655c2afaabbc79761b429330d0e7f069   openshift/origin-pod:v3.9.0                                                                                          "/usr/bin/pod"                                                                                                                                                                                     4 minutes ago       Up 4 minutes                            k8s_POD_docker-registry-1-xzc9d_default_95172d65-39a7-11e8-897e-02e44597d37c_0
f17f431b3979945c4fcc78ae7dc1b77910a6693874202c5d1776c363735c7f50   openshift/origin-pod:v3.9.0                                                                                          "/usr/bin/pod"                                                                                                                                                                                     4 minutes ago       Up 4 minutes                            k8s_POD_router-1-6q8n5_default_93ce263d-39a7-11e8-897e-02e44597d37c_0
deae0775c14779232ceeec542acc7017d247d15e4764e219e792c568a66b2c39   docker.io/openshift/origin-web-console@sha256:d8acfbd599fe7dcc550b4e0e89cff04aa3cef9dfb98657075b86c607a2237f6c       "/usr/bin/origin-web-console --audit-log-path=- -v=0 --config=/var/webconsole-config/webconsole-config.yaml"                                                                                       4 minutes ago       Up 4 minutes                            k8s_webconsole_webconsole-7dfbffd44d-542sz_openshift-web-console_8cb24f3b-39a7-11e8-897e-02e44597d37c_0
0147f439c40c92056ed1a84e9806184268fac158eca1242db2c048a153243bef   openshift/origin-pod:v3.9.0                                                                                          "/usr/bin/pod"                                                                                                                                                                                     5 minutes ago       Up 5 minutes                            k8s_POD_webconsole-7dfbffd44d-542sz_openshift-web-console_8cb24f3b-39a7-11e8-897e-02e44597d37c_0
3544bbba957c2573c9054adfb17410721129e1bcca2e3c435236abc56e24fb5b   openshift/origin:v3.9.0                                                                                              "/usr/bin/openshift start --master-config=/var/lib/origin/openshift.local.config/master/master-config.yaml --node-config=/var/lib/origin/openshift.local.config/node-localhost/node-config.yaml"   5 minutes ago       Up 5 minutes                            origin

```

## Access the cluster

```sh
$ oc login -u system:admin
$ oc version
oc v3.9.0+191fece
kubernetes v1.9.1+a0ce1bc657
features: Basic-Auth GSSAPI Kerberos SPNEGO

Server https://127.0.0.1:8443
openshift v3.9.0+191fece
kubernetes v1.9.1+a0ce1bc657
$ oc get node
NAME        STATUS    ROLES     AGE       VERSION
localhost   Ready     <none>    12m       v1.9.1+a0ce1bc657

$ oc get pod --all-namespaces
NAMESPACE               NAME                            READY     STATUS      RESTARTS   AGE
default                 docker-registry-1-xzc9d         1/1       Running     0          12m
default                 persistent-volume-setup-hh9r9   0/1       Completed   0          12m
default                 router-1-6q8n5                  1/1       Running     0          12m
openshift-web-console   webconsole-7dfbffd44d-542sz     1/1       Running     0          12m

$ oc new-project ttt
$ oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/rc_test.yaml
$ oc get pod -o wide
NAME               READY     STATUS    RESTARTS   AGE       IP           NODE
frontend-1-mh7qd   1/1       Running   0          1m        172.17.0.3   localhost
$ curl 172.17.0.3:8080
{"version":"0.0.1","ips":["127.0.0.1","::1","172.17.0.3","fe80::42:acff:fe11:3"],"now":"2018-04-06T14:58:18.754300842Z"}

$ oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/svc_test.yaml
service "my-service" created
$ oc get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
my-service   ClusterIP   172.30.45.107   <none>        8080/TCP   8s
[fedora@ip-172-31-22-241 ~]$ curl 172.30.45.107:8080
{"version":"0.0.1","ips":["127.0.0.1","::1","172.17.0.3","fe80::42:acff:fe11:3"],"now":"2018-04-06T15:00:00.190833934Z"}

### dns is not configured yet
### https://kubernetes.io/docs/concepts/services-networking/service/#dns
### 20181022: need to verify this again. See https://github.com/hongkailiu/svt-case-doc/blob/master/learn/networking.md#service-dns
$ curl my-service.ttt.svc
curl: (6) Could not resolve host: my-service.ttt.svc

$ oc expose svc my-service
$ oc get route
NAME         HOST/PORT                         PATH      SERVICES     PORT      TERMINATION   WILDCARD
my-service   my-service-ttt.127.0.0.1.nip.io             my-service   8080                    None
$ curl my-service-ttt.127.0.0.1.nip.io
{"version":"0.0.1","ips":["127.0.0.1","::1","172.17.0.3","fe80::42:acff:fe11:3"],"now":"2018-04-06T15:11:55.206682176Z"}

```

What is [nip.io](http://nip.io/). Looks so similar to xio.io. ^_^

## cluster-down

```sh
$ oc cluster down
$ oc cluster status
```

TODO: Would be nice if the cluster is accessible from other hosts.


## Use latest oc

Build master branch:

```bash
$ cd ${GOPATH}/src/github.com/openshift/origin
$ git checkout master 
$ git pull

$ make build WHAT=cmd/oc
$ ll _output/local/bin/linux/amd64/oc

$ _output/local/bin/linux/amd64/oc version
oc v4.0.0-alpha.0+181c59b-316-dirty
kubernetes v1.11.0+d4cacc0
features: Basic-Auth GSSAPI Kerberos SPNEGO

```

oc-cluster-up:

```bash
### on aws:
### SVT gold AMI works while fedora does not: might be an docker issue
$ metadata_endpoint="http://169.254.169.254/latest/meta-data"
$ public_hostname="$( curl "${metadata_endpoint}/public-hostname" )"
$ public_ip="$( curl "${metadata_endpoint}/public-ipv4" )"

$ _output/local/bin/linux/amd64/oc cluster up --public-hostname="${public_hostname}"

```
