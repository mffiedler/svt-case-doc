# Cluster Metrics

[Guideline](https://docs.openshift.org/latest/install_config/cluster_metrics.html)

### Modify [the inventory file](http://pastebin.test.redhat.com/503020)

* Update hostnames and openshift_metrics_image_version to match your cluster
* Upadte the subdomain for the openshift_metrics_hawkular_hostname which can be found in master-config.yaml or in your flexy job output.
  It will be mmdd-xxx.qe.rhcloud.com.
  
  ```sh
  # grep "qe.rhcloud.com" /etc/origin/master/master-config.yaml 
  subdomain:  "<mmdd>-<xxx>.qe.rhcloud.com"
  # docker images | grep ose
  ```

### Run [the playbook](https://github.com/openshift/openshift-ansible/blob/master/playbooks/byo/openshift-cluster/openshift-logging.yml)

```sh
# ansible-playbook -i /tmp/inv-metrics.file openshift-ansible/playbooks/byo/openshift-cluster/openshift-metrics.yml 
```

Check the parameter's meaning [here](https://docs.openshift.org/latest/install_config/aggregate_logging.html#install-config-aggregate-logging).

### Verify

```sh
# oc get pods -n openshift-infra
NAME                         READY     STATUS    RESTARTS   AGE
hawkular-cassandra-1-ppp7f   1/1       Running   0          3m
hawkular-metrics-k2w3t       1/1       Running   0          3m
heapster-jf3nz               1/1       Running   0          3m
```
