# Aggregate Logging

[Guideline](https://docs.openshift.org/latest/install_config/aggregate_logging_sizing.html)

## Installation via Ansible (Internal)
This

### Modify [the inventory file](http://pastebin.test.redhat.com/501979)

* Update hostnames and openshift_logging_image_version to match your cluster
* Upadte the subdomain for the kibana_hostname which can be found in master-config.yaml or in your flexy job output.
  It will be mmdd-xxx.qe.rhcloud.com.
  
  ```sh
  # grep "qe.rhcloud.com" /etc/origin/master/master-config.yaml 
  subdomain:  "<mmdd>-<xxx>.qe.rhcloud.com"
  # grep -i "masterPublicURL" /etc/origin/master/master-config.yaml
  # grep -i "masterURL" /etc/origin/master/master-config.yaml
  # docker images | grep ose
  ```

## Run [the playbook](https://github.com/openshift/openshift-ansible/blob/master/playbooks/byo/openshift-cluster/openshift-logging.yml)

```sh
# ansible-playbook -i /tmp/inv.file openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml
```

Check the parameter's meaning [here](https://docs.openshift.org/latest/install_config/aggregate_logging.html#install-config-aggregate-logging).

## Verify
