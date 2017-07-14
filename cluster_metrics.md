# Cluster Metrics

[Guideline](https://docs.openshift.org/latest/install_config/cluster_metrics.html)

### Modify [the inventory file](http://pastebin.test.redhat.com/503020)

```sh
# cat /tmp/inv-metrics.file
[oo_first_master]
172.31.47.236

[oo_first_master:vars]
openshift_deployment_type=openshift-enterprise
openshift_release=v3.6.0

openshift_metrics_install_metrics=true
openshift_metrics_hawkular_hostname=hawkular-metrics.0605-5ku.qe.rhcloud.com
openshift_metrics_project=openshift-infra
openshift_metrics_image_prefix=registry.ops.openshift.com/openshift3/
openshift_metrics_image_version=v3.6.140
openshift_metrics_cassandra_replicas=1
openshift_metrics_hawkular_replicas=1
openshift_metrics_cassandra_storage_type=dynamic
openshift_metrics_cassandra_pvc_size=100Gi
```

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

Check the parameter's meaning [here](https://docs.openshift.org/latest/install_config/cluster_metrics.html).

## Verify

### Terminal

```sh
# oc get pods -n openshift-infra
NAME                         READY     STATUS    RESTARTS   AGE
hawkular-cassandra-1-ppp7f   1/1       Running   0          3m
hawkular-metrics-k2w3t       1/1       Running   0          3m
heapster-jf3nz               1/1       Running   0          3m
```

### Web Console
_Note_ that one needs to logout/login to see it.


### docker container
SSH to cassandra docker container and then use [cassandra nodetool](http://docs.datastax.com/en/cassandra/3.0/cassandra/tools/toolsNodetool.html)
```sh
bash-4.2$ cassandra -v
cat: /etc/ld.so.conf.d/*.conf: No such file or directory
Picked up JAVA_TOOL_OPTIONS: -Duser.home=/home/jboss -Duser.name=jboss
3.0.14

bash-4.2$ nodetool status                                                                                                      
Picked up JAVA_TOOL_OPTIONS: -Duser.home=/home/jboss -Duser.name=jboss
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address      Load       Tokens       Owns (effective)  Host ID                               Rack
UN  172.20.1.83  3.91 MB    256          100.0%            980d834f-2c19-43aa-98de-663ad91163fd  rack1
```
