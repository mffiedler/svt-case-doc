# Service Catalog

"The end goal of the Service Catalog project is to provide a way for Kubernetes/OpenShift users to consume services from Brokers and easily configure their applications to use those services, without needing detailed knowledge of how those services are created or managed."

## Doc

* [svc_cat@k8s](https://github.com/kubernetes-incubator/service-catalog), [api](https://github.com/kubernetes-incubator/service-catalog/blob/master/docs/v1/api.md)
* [svc_cat@oc](https://docs.openshift.com/container-platform/3.6/architecture/service_catalog/index.html), [tr@3.6](https://blog.openshift.com/whats-new-openshift-3-6-service-catalog-brokers-tech-preview/), [release@3.7](https://blog.openshift.com/whats-new-in-openshift-3-7-service-catalog-and-brokers/)
* [intro_by_paul@youtube](https://www.youtube.com/watch?v=p35hOAAsxrQ), [deep dive](https://www.youtube.com/watch?time_continue=53&v=w48Och61tLg)
* [s3_svc_cat_demo@youtube](https://www.youtube.com/watch?v=-_m9Ijw3jWc&feature=youtu.be), [aws svc broker](https://blog.openshift.com/using-aws-openshift-together/)


## Installation on OC cluster

See [inventory/hosts.example](https://github.com/openshift/openshift-ansible/blob/master/inventory/hosts.example):

```
openshift_enable_service_catalog=true
openshift_service_catalog_image_prefix="registry.reg-aws.openshift.com:443/openshift3/ose-"
ansible_service_broker_image_prefix=registry.reg-aws.openshift.com:443/openshift3/ose-
ansible_service_broker_image_tag=v3.9
template_service_broker_prefix=registry.reg-aws.openshift.com:443/openshift3/ose-
template_service_broker_version=v3.9

```

So k8s service catalog is running under `kube-service-catalog`:

```sh
# oc get all -n kube-service-catalog
NAME                    DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR               AGE
ds/apiserver            1         1         1         1            1           openshift-infra=apiserver   5h
ds/controller-manager   1         1         1         1            1           openshift-infra=apiserver   5h

NAME               HOST/PORT                                                     PATH      SERVICES    PORT      TERMINATION   WILDCARD
routes/apiserver   apiserver-kube-service-catalog.apps.0320-ve1.qe.rhcloud.com             apiserver   secure    passthrough   None

NAME                          READY     STATUS    RESTARTS   AGE
po/apiserver-zslpb            1/1       Running   0          5h
po/controller-manager-hg979   1/1       Running   0          5h

NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
svc/apiserver   ClusterIP   172.27.249.47   <none>        443/TCP   5h

```

With `kube-service-catalog`, we can provide `ClusterServiceBroker` which implements the services.
Out of the box, Openshift ships 2 brokers:

```sh
# oc get ClusterServiceBroker
NAME                      AGE
ansible-service-broker    4h
template-service-broker   4h

# oc get ClusterServiceClass
# oc get ClusterServicePlan

# oc get ServiceInstance --all-namespaces
# oc get ServiceBinding --all-namespaces

```

## [Template service broker](https://docs.openshift.com/container-platform/3.7/architecture/service_catalog/template_service_broker.html)

For the moment, all application services (the applications showing up on the web UI, service catalog page) shipped by Openshift are managed by this broker.
_Note that_ there should be other services from other brokers too, eg, `ansible-service-broker`. I believe that `asb` is NOT working yet.

```sh
# oc get templates -n openshift --no-headers | wc -l
143
# oc get ClusterServiceClass --no-headers | wc -l
143
# oc get ClusterServiceClass --no-headers -o yaml | grep clusterServiceBrokerName | grep "template-service-broker" | wc -l
143

```

Observe that NOT all 143 cluster service classes show up in the UI, instead only 100 do.
It is NOT pagination. 100 is a nice and misleading number.


Let us do it on the UI:

* create in namespace `hhh` a Node.js + MongoDB `service instance` and then

```sh
# oc get ServiceInstance -n hhh
NAME                            AGE
nodejs-mongo-persistent-sz94s   4m

```

* (FOR some reason, Jenkins pod is not running: bz???) create in namespace `ccc` a Jenkins `service instance` and a `service binding` and then

```sh
# oc get ServiceInstance --all-namespaces
NAMESPACE   NAME                       AGE
ccc         jenkins-persistent-g2nvv   2m

# oc get ServiceBinding --all-namespaces
NAMESPACE   NAME                             AGE
ccc         jenkins-persistent-g2nvv-9lfcx   2m

```


## [Ansible service broker](https://docs.openshift.com/container-platform/3.7/architecture/service_catalog/ansible_service_broker.html)

src: [ansible-service-broker](https://github.com/openshift/ansible-service-broker)

Follow [the example](https://docs.openshift.com/container-platform/3.7/apb_devel/index.html#apb-devel-intro-design) in the doc and
[Case OCP-15042](https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-15042) from Beijing team
covers this example.


On master:

```sh
# yum install -y apb

```

The example did not work: https://bugzilla.redhat.com/show_bug.cgi?id=1558231
Update on 20180410: Follow [Comment 1](https://bugzilla.redhat.com/show_bug.cgi?id=1558231#c1) there and `apb list` works:
* docker config add local docker registry as insecure reg
* change the whitelist in the configMap
* `apb push --registry-route`

Check config which is made up [here](https://github.com/openshift/openshift-ansible/blob/release-3.9/roles/ansible_service_broker/tasks/install.yml#L381).
The meaning of parameters in the config is [here](https://github.com/openshift/ansible-service-broker/blob/master/docs/config.md).

```sh
# oc exec -n openshift-ansible-service-broker asb-1-ccbdh cat /etc/ansible-service-broker/config.yaml
registry:
  - type: rhcc
    name: rh
    url:  https://registry.access.redhat.com
    org:
    tag:  v3.9.11
    white_list: [.*-apb$]

    auth_type: ""
    auth_name: ""
  - type: local_openshift
    name: localregistry
    namespaces: ['openshift']
    white_list: []
...
```

Debugging doc: https://github.com/openshift/ansible-service-broker/blob/master/docs/debugging.md


## Add a 3rd party broker

Follow [Case OCP-15602](https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-15602) and it comes from
[walkthrough.md](https://github.com/kubernetes-incubator/service-catalog/blob/master/docs/walkthrough.md) of k8s-service-catalog repo.

```sh
# oc new-project ups-service-broker
# oc create -f https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/svc-catalog/ups-broker-deploy.yaml
deployment "ups-broker" created
root@ip-172-31-43-179: ~ # oc create -f https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/svc-catalog/ups-broker-svc.yaml
service "ups-broker" created

### Cannot use the template directly. Need to modify the url
# wget https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/svc-catalog/ups-broker-3.7.yaml
# vi ups-broker-3.7.yaml
...
spec:
  url: http://ups-broker.ups-service-broker.svc

# oc create -f ./ups-broker-3.7.yaml
clusterservicebroker "ups-broker" created

### Checking
# oc get clusterservicebroker
NAME                      AGE
ansible-service-broker    7h
template-service-broker   7h
ups-broker                31s

# oc describe clusterservicebroker ups-broker
...
Events:
  Type    Reason          Age   From                                Message
  ----    ------          ----  ----                                -------
  Normal  FetchedCatalog  1m    service-catalog-controller-manager  Successfully fetched catalog entries from broker.

# oc get clusterserviceclass -o=custom-columns=NAME:.metadata.name,EXTERNAL\ NAME:.spec.externalName | grep user
4f6e6cf6-ffdd-425f-a2c7-3c9258ad2468   user-provided-service
5f6e6cf6-ffdd-425f-a2c7-3c9258ad2468   user-provided-service-single-plan

### by the age columns we know that 3 clusterserviceplan are added
### Here we use another tool to check plans associated with each class
### https://github.com/kubernetes-incubator/service-catalog/blob/master/docs/install.md#linux

# curl -sLO https://download.svcat.sh/cli/latest/linux/amd64/svcat
# chmod +x ./svcat
# mv ./svcat /usr/local/bin/
# svcat --version
svcat v0.1.10

# svcat describe class user-provided-service
  Name:          user-provided-service
  Description:   A user provided service
  UUID:          4f6e6cf6-ffdd-425f-a2c7-3c9258ad2468
  Status:        Active
  Tags:
  Broker:        ups-broker

Plans:
   NAME           DESCRIPTION
+---------+-------------------------+
  default   Sample plan description
  premium   Premium plan

# svcat describe class user-provided-service-single-plan
  Name:          user-provided-service-single-plan
  Description:   A user provided service
  UUID:          5f6e6cf6-ffdd-425f-a2c7-3c9258ad2468
  Status:        Active
  Tags:
  Broker:        ups-broker

Plans:
   NAME           DESCRIPTION
+---------+-------------------------+
  default   Sample plan description

```

Check on the web UI, those 2 services should show up. If not, logout and login.

Create service instance of `user-provided-service` on the UI for project `ttt` and choose binding.

```sh
### Checking
root@ip-172-31-43-179: ~ # oc get serviceinstance -n ttt
NAME                          AGE
user-provided-service-wvp7p   3m
root@ip-172-31-43-179: ~ # oc get servicebinding -n ttt
NAME                                AGE
user-provided-service-wvp7p-npbj5   4m

```

Potential bz: If we delete `ups-broker` and then delete project `ttt`, then `ttt` is terminating forever.
I think it is because `serviceinstance` as resources of `ttt` cannot be deleted up to the missing broker.

## [CNS-S3 as service via service catalog](https://docs.google.com/document/d/1OEmlXTpQ1F3Ni0LDVM12zA2f7B2Xs7Wdq94y8sW6ANQ/edit)


## Questions from Mike

* We have a very cool template for my app, how can I make it available on the UI?

  My answer:

  * via template-service-broker: I believe that it is the right way. But I need to understand how the broker works first.
  * via ansible-service-broker: This should be easy when I get the fix of the above bz.
  * via our own broker: This is the hardest way, but I will learn the most out of it.

* If we have lots of services into the web UI, would it explode?

  My answer: Yes. No pagination yet on the UI.
