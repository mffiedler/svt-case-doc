# Cluster Metrics


## Doc

[Guideline](https://docs.openshift.org/latest/install_config/cluster_metrics.html)

## Data flow

k8s cluster - [Heapster](https://github.com/kubernetes/heapster) - [Hawkular-metrics](https://github.com/hawkular/hawkular-metrics) - [cassandra](http://cassandra.apache.org/)

All those above components are put together with [origin-metics](https://github.com/openshift/origin-metrics).

## Installation

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

Check the parameter's meaning [here](https://docs.openshift.org/latest/install_config/cluster_metrics.html) and [here](https://github.com/openshift/openshift-ansible/tree/master/roles/openshift_metrics).

## Verify

### Terminal

```sh
# oc project openshift-infra
# oc get all
NAME                      HOST/PORT                                       PATH      SERVICES           PORT      TERMINATION   WILDCARD
routes/hawkular-metrics   hawkular-metrics.apps.0927-7l0.qe.rhcloud.com             hawkular-metrics   <all>     reencrypt     None

NAME                            READY     STATUS    RESTARTS   AGE
po/hawkular-cassandra-1-hfmhh   1/1       Running   0          2m
po/hawkular-metrics-sq1nb       1/1       Running   0          2m
po/heapster-p780l               1/1       Running   0          2m

NAME                      DESIRED   CURRENT   READY     AGE
rc/hawkular-cassandra-1   1         1         1         2m
rc/hawkular-metrics       1         1         1         3m
rc/heapster               1         1         1         3m

NAME                           CLUSTER-IP       EXTERNAL-IP   PORT(S)                               AGE
svc/hawkular-cassandra         172.25.228.142   <none>        9042/TCP,9160/TCP,7000/TCP,7001/TCP   3m
svc/hawkular-cassandra-nodes   None             <none>        9042/TCP,9160/TCP,7000/TCP,7001/TCP   3m
svc/hawkular-metrics           172.26.197.91    <none>        443/TCP                               3m
svc/heapster                   172.27.224.4     <none>        80/TCP                                3m

# oc get pvc
NAME                  STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
metrics-cassandra-1   Bound     pvc-a0380ff9-a3ae-11e7-bc27-025e587a7470   100Gi      RWO           gp2            3m

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

## Cleanup before Redeployment

Stole from [Mike's gist](https://gist.github.com/mffiedler/d20c37f28ab0a1190fbd592e429e29f4):

```sh
# oc project openshift-infra
# oc delete --all rc
# oc delete --all po
# oc delete --all svc
# oc delete --all route
# oc delete --all pvc
# oc delete sa heapster hawkular cassandra
# oc delete secrets hawkular-cassandra-certs hawkular-metrics-account hawkular-metrics-certs heapster-certs heapster-secrets
```
