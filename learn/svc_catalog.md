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

All application templates shipped by Openshift are managed by this broker.

```sh
# oc get templates -n openshift --no-headers | wc -l
143
# oc get ClusterServiceClass --no-headers | wc -l
143
# oc get ClusterServiceClass --no-headers -o yaml | grep clusterServiceBrokerName | grep "template-service-broker" | wc -l
143

```

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

Follow [the example](https://docs.openshift.com/container-platform/3.7/apb_devel/index.html#apb-devel-intro-design) in the doc:


On master:

```sh
# yum install -y apb

```

The example did not work: https://bugzilla.redhat.com/show_bug.cgi?id=1558231


Check config:

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


## [CNS-S3 as service via service catalog](https://docs.google.com/document/d/1OEmlXTpQ1F3Ni0LDVM12zA2f7B2Xs7Wdq94y8sW6ANQ/edit)
