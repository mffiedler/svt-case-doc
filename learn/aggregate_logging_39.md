# Aggregate Logging

[Guideline](https://docs.openshift.org/latest/install_config/aggregate_logging.html)

## Installation via Ansible (Internal)
Installation is performed on master.


Check the logging driver:

```sh
# docker info 
...
Logging Driver: json-file
...
```

### Modify the inventory file

json-file without mux:

```sh
[OSEv3:vars]
...
openshift_logging_install_logging=true
openshift_logging_storage_kind=dynamic
openshift_logging_image_prefix=registry.reg-aws.openshift.com:443/openshift3/
openshift_logging_image_version=v3.9


openshift_logging_es_cluster_size=1
openshift_logging_es_pvc_dynamic=true
openshift_logging_es_pvc_size=50Gi
openshift_logging_fluentd_use_journal=false

##openshift_logging_use_mux=true
openshift_logging_use_mux=false
## openshift_logging_mux_client_mode=maximal
openshift_logging_use_ops=false

openshift_logging_es_cpu_limit=2000m
openshift_logging_es_memory_limit=9Gi
openshift_logging_fluentd_cpu_limit=1000m
## openshift_logging_mux_cpu_limit=1000m
openshift_logging_fluentd_memory_limit=1024Mi
openshift_logging_kibana_cpu_limit=200m
openshift_logging_kibana_proxy_cpu_limit=100m
## openshift_logging_mux_memory_limit=2Gi
openshift_logging_kibana_memory_limit=1Gi
openshift_logging_kibana_proxy_memory_limit=256Mi
openshift_logging_fluentd_buffer_size_limit=16m

```

### Run [the playbook](https://github.com/openshift/openshift-ansible/blob/master/playbooks/byo/openshift-cluster/openshift-logging.yml)

```sh
# ansible-playbook -i /tmp/inv.file openshift-ansible/playbooks/openshift-logging/config.yml
```

Check the parameter's meaning [here](https://docs.openshift.org/latest/install_config/aggregate_logging.html#install-config-aggregate-logging) and [here](https://github.com/openshift/openshift-ansible/blob/master/roles/openshift_logging/README.md).

## Verify

```sh
# oc project logging
# oc get all -o wide
NAME                                                REVISION   DESIRED   CURRENT   TRIGGERED BY
deploymentconfigs/logging-curator                   1          1         1         config
deploymentconfigs/logging-es-data-master-hye5503q   1          1         1         
deploymentconfigs/logging-kibana                    1          1         1         config

NAME                    HOST/PORT                             PATH      SERVICES         PORT      TERMINATION          WILDCARD
routes/logging-kibana   kibana.apps.0102-7j8.qe.rhcloud.com             logging-kibana   <all>     reencrypt/Redirect   None

NAME                 DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR                AGE       CONTAINERS              IMAGES                                                               SELECTOR
ds/logging-fluentd   4         4         4         4            4           logging-infra-fluentd=true   3m        fluentd-elasticsearch   registry.reg-aws.openshift.com:443/openshift3/logging-fluentd:v3.9   component=fluentd,provider=openshift
ds/logging-fluentd   4         4         4         4            4           logging-infra-fluentd=true   3m        fluentd-elasticsearch   registry.reg-aws.openshift.com:443/openshift3/logging-fluentd:v3.9   component=fluentd,provider=openshift

NAME                                                REVISION   DESIRED   CURRENT   TRIGGERED BY
deploymentconfigs/logging-curator                   1          1         1         config
deploymentconfigs/logging-es-data-master-hye5503q   1          1         1         
deploymentconfigs/logging-kibana                    1          1         1         config

NAME                    HOST/PORT                             PATH      SERVICES         PORT      TERMINATION          WILDCARD
routes/logging-kibana   kibana.apps.0102-7j8.qe.rhcloud.com             logging-kibana   <all>     reencrypt/Redirect   None

NAME                                         READY     STATUS    RESTARTS   AGE       IP            NODE
po/logging-curator-1-4f2ng                   1/1       Running   0          4m        172.21.0.9    ip-172-31-53-183.us-west-2.compute.internal
po/logging-es-data-master-hye5503q-1-g4w27   2/2       Running   0          3m        172.21.0.11   ip-172-31-53-183.us-west-2.compute.internal
po/logging-fluentd-56v9v                     1/1       Running   0          3m        172.20.0.7    ip-172-31-53-99.us-west-2.compute.internal
po/logging-fluentd-btg4v                     1/1       Running   0          3m        172.22.0.7    ip-172-31-51-92.us-west-2.compute.internal
po/logging-fluentd-d2vbl                     1/1       Running   0          3m        172.23.0.3    ip-172-31-1-162.us-west-2.compute.internal
po/logging-fluentd-gf8rq                     1/1       Running   0          3m        172.21.0.10   ip-172-31-53-183.us-west-2.compute.internal
po/logging-kibana-1-7pp95                    2/2       Running   0          4m        172.22.0.6    ip-172-31-51-92.us-west-2.compute.internal

NAME                                   DESIRED   CURRENT   READY     AGE       CONTAINERS            IMAGES                                                                                                                                    SELECTOR
rc/logging-curator-1                   1         1         1         4m        curator               registry.reg-aws.openshift.com:443/openshift3/logging-curator:v3.9                                                                        component=curator,deployment=logging-curator-1,deploymentconfig=logging-curator,logging-infra=curator,provider=openshift
rc/logging-es-data-master-hye5503q-1   1         1         1         3m        proxy,elasticsearch   registry.reg-aws.openshift.com:443/openshift3/oauth-proxy:v3.9,registry.reg-aws.openshift.com:443/openshift3/logging-elasticsearch:v3.9   component=es,deployment=logging-es-data-master-hye5503q-1,deploymentconfig=logging-es-data-master-hye5503q,logging-infra=elasticsearch,provider=openshift
rc/logging-kibana-1                    1         1         1         4m        kibana,kibana-proxy   registry.reg-aws.openshift.com:443/openshift3/logging-kibana:v3.9,registry.reg-aws.openshift.com:443/openshift3/logging-auth-proxy:v3.9   component=kibana,deployment=logging-kibana-1,deploymentconfig=logging-kibana,logging-infra=kibana,provider=openshift

NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE       SELECTOR
svc/logging-es              ClusterIP   172.25.219.160   <none>        9200/TCP   4m        component=es,provider=openshift
svc/logging-es-cluster      ClusterIP   172.27.202.178   <none>        9300/TCP   4m        component=es,provider=openshift
svc/logging-es-prometheus   ClusterIP   172.24.155.58    <none>        443/TCP    4m        component=es,provider=openshift
svc/logging-kibana          ClusterIP   172.26.122.102   <none>        443/TCP    4m        component=kibana,provider=openshift
root@ip-172-31-1-162: ~ # 


# oc get ds
NAME              DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR                AGE
logging-fluentd   4         4         4         4            4           logging-infra-fluentd=true   4m

# oc get pvc
NAME           STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
logging-es-0   Bound     pvc-2da10146-eff1-11e7-b323-0291a6ab3956   50Gi       RWO            io1            5m

# oc get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                  STORAGECLASS   REASON    AGE
pvc-2da10146-eff1-11e7-b323-0291a6ab3956   50Gi       RWO            Delete           Bound     logging/logging-es-0   io1                      6m

# POD=logging-es-data-master-hye5503q-1-g4w27
# oc exec $POD -- curl --connect-timeout 2 -s -k --cert /etc/elasticsearch/secret/admin-cert --key /etc/elasticsearch/secret/admin-key https://logging-es:9200/_cat/indices?v
Defaulting container name to proxy.
Use 'oc describe pod/logging-es-data-master-hye5503q-1-g4w27 -n logging' to see all of the containers in this pod.
health status index                                                           pri rep docs.count docs.deleted store.size pri.store.size 
green  open   project.logging.dc258656-eff0-11e7-b323-0291a6ab3956.2018.01.02   1   0        309            0    484.7kb        484.7kb 
green  open   .searchguard.logging-es-data-master-hye5503q                      1   0          5            0     33.5kb         33.5kb 
green  open   .kibana                                                           1   0          1            0      3.1kb          3.1kb 
green  open   .operations.2018.01.02                                            1   0       2835            0      3.6mb          3.6mb 


```

If we need to redeplay the logging stack, we can delete logging project and recreate it, and then rerun the above playbook:

```sh
# oc delete project logging
# oc adm new-project logging --node-selector=""
```

## Search (logs in Kibana)
Aggregate logging in Openshift collects, stores, and indexes logs genrated in the cluster. Eg, docker container logs.
Copy a keyword in the log entries, input it in the search box on Kibana web UI. We should see it in the returned results.

* On the top of navigation tree, choose <code>.all</code> which search all indecies in ElasticSearch.
* Choose a proper time range, *the last 15 mins* is the default.



```sh
# oc new-project aaa
Now using project "aaa" on server "https://ip-172-31-5-155.us-west-2.compute.internal:8443".

# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/rc_test.yaml
replicationcontroller "frontend-1" created

# oc get pod -o wide
NAME               READY     STATUS    RESTARTS   AGE       IP           NODE
frontend-1-pklzq   1/1       Running   0          5m        172.23.0.9   ip-172-31-5-234.us-west-2.compute.internal

# curl -H "Content-Type: application/json" -X POST -d '{"line":"abcd"}' http://172.23.0.9:8080/logs
201 - Log entries created.

# oc logs frontend-1-pklzq
2017-09-22T14:48:19.780+0000 Debug ▶ DEBU 001 [aaa]
2017-09-22T14:56:46.245+0000 Info ▶ INFO 002 [abcd]

# oc exec -n logging $POD -- curl --connect-timeout 2 -s -k --cert /etc/elasticsearch/secret/admin-cert --key /etc/elasticsearch/secret/admin-key https://logging-es:9200/_cat/indices?v
health status index                                                           pri rep docs.count docs.deleted store.size pri.store.size 
...
green  open   project.aaa.dbe525d1-9fa4-11e7-8793-027497ece8ac.2017.09.22       1   0          2            0       48kb           48kb 

```


## Logging test tool
Check [this](https://github.com/openshift/svt/blob/master/openshift_scalability/content/logtest/ocp_logtest-README.md)
out.

## Reference

[1]. https://medium.com/@yoanis_gil/logging-with-docker-part-1-b23ef1443aac

[2]. http://www.projectatomic.io/blog/2015/04/logging-docker-container-output-to-journald/

[3]. https://www.loggly.com/ultimate-guide/using-journalctl/
