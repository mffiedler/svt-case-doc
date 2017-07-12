# Aggregate Logging

[Guideline](https://docs.openshift.org/latest/install_config/aggregate_logging.html)

## Installation via Ansible (Internal)
Installation is performed on master.

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

### Run [the playbook](https://github.com/openshift/openshift-ansible/blob/master/playbooks/byo/openshift-cluster/openshift-logging.yml)

```sh
# ansible-playbook -i /tmp/inv.file openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml
```

Check the parameter's meaning [here](https://docs.openshift.org/latest/install_config/aggregate_logging.html#install-config-aggregate-logging).

## Verify

```sh
$ oc project logging
$ oc get pods
```

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

New pods will be deployed automatically after dc is updated. The daemonset (https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
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

