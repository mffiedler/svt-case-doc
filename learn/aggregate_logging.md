# Aggregate Logging

[Guideline](https://docs.openshift.org/latest/install_config/aggregate_logging.html)

## Installation via Ansible (Internal)
Installation is performed on master.

### Modify the inventory file

```sh
[oo_first_master]
ip-172-31-31-159

[oo_first_master:vars]
openshift_deployment_type=openshift-enterprise
openshift_release=v3.6.0

openshift_logging_install_logging=true
openshift_logging_use_ops=false
openshift_logging_master_url=https://ec2-34-223-225-62.us-west-2.compute.amazonaws.com:8443
openshift_logging_master_public_url=https://ec2-34-223-225-62.us-west-2.compute.amazonaws.com:8443
openshift_logging_kibana_hostname=kibana.0620-8i0.qe.rhcloud.com
openshift_logging_namespace=logging
openshift_logging_image_prefix=registry.ops.openshift.com/openshift3/
openshift_logging_image_version=v3.6.116
openshift_logging_es_pvc_dynamic=true
openshift_logging_es_pvc_size=50Gi
openshift_logging_fluentd_use_journal=true
openshift_logging_use_mux=true
openshift_logging_use_mux_client=true
```


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

Note that <code>openshift_logging_fluentd_use_journal</code> tells _fluentd_ to checkout container logs from _journald_.

### Run [the playbook](https://github.com/openshift/openshift-ansible/blob/master/playbooks/byo/openshift-cluster/openshift-logging.yml)

```sh
# ansible-playbook -i /tmp/inv.file openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml
```

Check the parameter's meaning [here](https://docs.openshift.org/latest/install_config/aggregate_logging.html#install-config-aggregate-logging).

## Verify

```sh
$ oc project logging
$ oc get pods
$ oc get pvc
NAME           STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
logging-es-0   Bound     pvc-d97744c7-670f-11e7-9ab4-028b0ef184e0   50Gi       RWO           gp2            7h
$ oc get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                  STORAGECLASS   REASON    AGE
pvc-d97744c7-670f-11e7-9ab4-028b0ef184e0   50Gi       RWO           Delete          Bound     logging/logging-es-0   gp2                      7h
```

Note that PV is attached to ES-pods.

Assume that we put a wrong value of openshift_logging_image_version, eg, the image does not exist. We would see

  > logging     logging-fluentd-341q7                      0/1       ImagePullBackOff   0          6m

The proof of non-existing image is <code>oc get events | grep -i warn | grep -i fluentd</code>
  
  > Failed to pull image ...

Instead of deleting the project and rerun the playbook, we can fix this by correcting image version in all dc(s) and ds:

```sh
# oc get dc
NAME                              REVISION   DESIRED   CURRENT   TRIGGERED BY
logging-curator                   2          1         1         config
logging-es-data-master-ob9e0uqd   2          1         1         config
logging-kibana                    3          1         1         config
logging-mux                       2          1         1         config
# oc edit dc <dc_name>
# oc get ds
NAME              DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE-SELECTOR                AGE
logging-fluentd   4         4         4         4            4           logging-infra-fluentd=true   21m
# oc get ds logging-fluentd -o yaml --export > logging-fluentd.yaml
# oc delete ds logging-fluentd
# oc delete pod logging-curator-1-deploy logging-es-data-master-ob9e0uqd-1-deploy logging-mux-1-deploy
# vi logging-fluentd.yaml
# oc create -f logging-fluentd.yaml
```

New pods will be deployed automatically after dc is updated. The [daemonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
for fluentd is handled differently: export a file and edit it manually.

The correct status of pods

```sh# oc get pods
NAME                                      READY     STATUS    RESTARTS   AGE
logging-curator-2-zd13p                   1/1       Running   0          29m
logging-es-data-master-ob9e0uqd-2-4xzk7   1/1       Running   0          28m
logging-fluentd-cxp78                     1/1       Running   0          23m
logging-fluentd-n2tzl                     1/1       Running   0          23m
logging-fluentd-n56hz                     1/1       Running   0          23m
logging-fluentd-nqxn0                     1/1       Running   0          23m
logging-kibana-3-bnkfv                    2/2       Running   0          22m
logging-mux-2-kbcw7                       1/1       Running   0          27m
```

*Note* that the dataflow is fluentd(s), es, kibana, curator (for cleanups).

If we need to redeplay the logging stack, we can delete logging project and recreate it, and then rerun the above playbook:

```sh
# cat /tmp/logging.project.yaml 
apiVersion: v1
kind: Project
metadata:
  annotations:
    openshift.io/description: ""
    openshift.io/display-name: ""
    openshift.io/sa.scc.mcs: s0:c8,c2
    openshift.io/sa.scc.supplemental-groups: 1000060000/10000
    openshift.io/sa.scc.uid-range: 1000060000/10000
  creationTimestamp: 2017-07-14T01:36:56Z
  name: logging
  resourceVersion: "1617"
  selfLink: /oapi/v1/projects/logging
  uid: ebce4a9f-6834-11e7-b351-021cdd15ec52
spec:
  finalizers:
  - openshift.io/origin
  - kubernetes
status:
  phase: Active
# oc create -f /tmp/logging.project.yaml
```

## Search (logs in Kibana)
Aggregate logging in Openshift collects, stores, and indexes logs genrated in the cluster. Eg, docker container logs.
Copy a keyword in the log entries, input it in the search box on Kibana web UI. We should see it in the returned results.

* On the top of navigation tree, choose <code>.all</code> which search all indecies in ElasticSearch.
* Choose a proper time range, *the last 15 mins* is the default.



## How it works (partially)

### docker logs

#### journald
Check [docker config for logging](https://docs.docker.com/engine/admin/logging/overview/#supported-logging-drivers):

```sh
# docker info | grep "Logging Driver"
Logging Driver: journald
```

In this case, this is <code>journald</code>.

[Retrieve the container logs](https://docs.docker.com/engine/admin/logging/journald/#retrieving-log-messages-with-journalctl)

```sh
# journalctl -b CONTAINER_NAME=<CONTAINER_NAME>
```

#### json-file

Change _docker daemon_ options by <code>/etc/docker/daemon.json</code>:

```sh
# cat /etc/docker/daemon.json 
{
"log-driver": "json-file"
}
# systemctl restart docker
# docker info | grep "Logging Driver"
Logging Driver: json-file
```
Log file locations:

```sh
# ls /var/lib/docker/containers/1962de2f6e3f645fa20e21c107763f71d7f0db1fce9e82021b79a68d043be35a/1962de2f6e3f645fa20e21c107763f71d7f0db1fce9e82021b79a68d043be35a-json.log
```

*Note* that if the logging driver of docker is changed. Logging stack needs to be reinstalled in order for _fluentd_ to redecide where to pick logs up. 

TODO find if there is a better solution for this.

### Recreate logging project

```sh
# oadm new-project logging --node-selector=""
```


### Logging test tool
Check [this](https://github.com/openshift/svt/blob/master/openshift_scalability/content/logtest/ocp_logtest-README.md)
out.

## Reference

[1]. https://medium.com/@yoanis_gil/logging-with-docker-part-1-b23ef1443aac

[2]. http://www.projectatomic.io/blog/2015/04/logging-docker-container-output-to-journald/

[3]. https://www.loggly.com/ultimate-guide/using-journalctl/
