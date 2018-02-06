# Prometheus

## doc

* [prometheus.io](https://prometheus.io/)
* [prometheus@github](https://github.com/prometheus)


## [Get started](https://prometheus.io/docs/introduction/getting_started/)

Tested on Fedora26:

## Prometheus@oc

* [doc@origin](https://github.com/openshift/origin/tree/master/examples/prometheus)
* [p@oc-blog](https://blog.openshift.com/tag/prometheus/)
* [gap-archetecture](https://blog.openshift.com/monitoring-openshift-three-tools/)

## Installation

* On a new cluster:

```
### the inv. file contains those vars:
openshift_hosted_prometheus_deploy=true
openshift_prometheus_image_prefix=registry.reg-aws.openshift.com:443/openshift3/
openshift_prometheus_image_version=v3.9
openshift_prometheus_proxy_image_prefix=registry.reg-aws.openshift.com:443/openshift3/
openshift_prometheus_proxy_image_version=v3.9
openshift_prometheus_alertmanager_image_prefix=registry.reg-aws.openshift.com:443/openshift3/
openshift_prometheus_alertmanager_image_version=v3.9
openshift_prometheus_alertbuffer_image_prefix=registry.reg-aws.openshift.com:443/openshift3/
openshift_prometheus_alertbuffer_image_version=v3.9

$ ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/deploy_cluster.yml
```

* On an existing cluster:

```
### the inv. file contains same vars as above.
$ ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/openshift-prometheus/config.yml
```

Example of inv. file is [here](https://github.com/openshift/openshift-ansible/tree/master/roles/openshift_prometheus) and the meaning of inv. vars is [here](https://github.com/openshift/openshift-ansible/blob/master/inventory/hosts.example).
