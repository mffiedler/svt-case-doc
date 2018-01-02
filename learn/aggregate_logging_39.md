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
deploymentconfigs/logging-es-data-master-39f9joda   1          1         1         config
deploymentconfigs/logging-es-data-master-43lag4ik   1          1         1         config
deploymentconfigs/logging-es-data-master-j763alrc   1          1         1         config
deploymentconfigs/logging-kibana                    1          1         1         config
deploymentconfigs/logging-mux                       1          1         1         config

NAME                    HOST/PORT                             PATH      SERVICES         PORT      TERMINATION          WILDCARD
routes/logging-kibana   kibana.apps.0922-mtp.qe.rhcloud.com             logging-kibana   <all>     reencrypt/Redirect   None

NAME                                         READY     STATUS    RESTARTS   AGE       IP            NODE
po/logging-curator-1-xzmk3                   1/1       Running   0          4m        172.20.2.17   ip-172-31-21-185.us-west-2.compute.internal
po/logging-es-data-master-39f9joda-1-p2qg2   1/1       Running   0          4m        172.23.0.7    ip-172-31-5-234.us-west-2.compute.internal
po/logging-es-data-master-43lag4ik-1-z383x   1/1       Running   0          4m        172.21.0.5    ip-172-31-23-229.us-west-2.compute.internal
po/logging-es-data-master-j763alrc-1-v1g9g   1/1       Running   0          4m        172.20.0.6    ip-172-31-10-173.us-west-2.compute.internal
po/logging-fluentd-03nz4                     1/1       Running   0          3m        172.22.0.3    ip-172-31-5-155.us-west-2.compute.internal
po/logging-fluentd-633f9                     1/1       Running   0          3m        172.20.2.19   ip-172-31-21-185.us-west-2.compute.internal
po/logging-fluentd-8qk3x                     1/1       Running   0          3m        172.21.0.6    ip-172-31-23-229.us-west-2.compute.internal
po/logging-fluentd-c9wh1                     1/1       Running   0          3m        172.23.0.8    ip-172-31-5-234.us-west-2.compute.internal
po/logging-fluentd-v59b7                     1/1       Running   0          3m        172.20.0.7    ip-172-31-10-173.us-west-2.compute.internal
po/logging-kibana-1-0xmzz                    2/2       Running   0          4m        172.20.2.15   ip-172-31-21-185.us-west-2.compute.internal
po/logging-mux-1-kb1h9                       1/1       Running   0          3m        172.20.2.20   ip-172-31-21-185.us-west-2.compute.internal

NAME                                   DESIRED   CURRENT   READY     AGE       CONTAINER(S)          IMAGE(S)                                                                                                                      SELECTOR
rc/logging-curator-1                   1         1         1         4m        curator               registry.ops.openshift.com/openshift3/logging-curator:v3.7.0                                                                  component=curator,deployment=logging-curator-1,deploymentconfig=logging-curator,logging-infra=curator,provider=openshift
rc/logging-es-data-master-39f9joda-1   1         1         1         4m        elasticsearch         registry.ops.openshift.com/openshift3/logging-elasticsearch:v3.7.0                                                            component=es,deployment=logging-es-data-master-39f9joda-1,deploymentconfig=logging-es-data-master-39f9joda,logging-infra=elasticsearch,provider=openshift
rc/logging-es-data-master-43lag4ik-1   1         1         1         4m        elasticsearch         registry.ops.openshift.com/openshift3/logging-elasticsearch:v3.7.0                                                            component=es,deployment=logging-es-data-master-43lag4ik-1,deploymentconfig=logging-es-data-master-43lag4ik,logging-infra=elasticsearch,provider=openshift
rc/logging-es-data-master-j763alrc-1   1         1         1         4m        elasticsearch         registry.ops.openshift.com/openshift3/logging-elasticsearch:v3.7.0                                                            component=es,deployment=logging-es-data-master-j763alrc-1,deploymentconfig=logging-es-data-master-j763alrc,logging-infra=elasticsearch,provider=openshift
rc/logging-kibana-1                    1         1         1         4m        kibana,kibana-proxy   registry.ops.openshift.com/openshift3/logging-kibana:v3.7.0,registry.ops.openshift.com/openshift3/logging-auth-proxy:v3.7.0   component=kibana,deployment=logging-kibana-1,deploymentconfig=logging-kibana,logging-infra=kibana,provider=openshift
rc/logging-mux-1                       1         1         1         3m        mux                   registry.ops.openshift.com/openshift3/logging-fluentd:v3.7.0                                                                  component=mux,deployment=logging-mux-1,deploymentconfig=logging-mux,logging-infra=mux,provider=openshift

NAME                     CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE       SELECTOR
svc/logging-es           172.24.228.83   <none>        9200/TCP    5m        component=es,provider=openshift
svc/logging-es-cluster   172.26.91.224   <none>        9300/TCP    5m        component=es,provider=openshift
svc/logging-kibana       172.27.70.64    <none>        443/TCP     4m        component=kibana,provider=openshift
svc/logging-mux          172.26.41.150   <none>        24284/TCP   3m        component=mux,provider=openshift


# oc get ds
NAME              DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE-SELECTOR                AGE
logging-fluentd   5         5         5         5            5           logging-infra-fluentd=true   8m

# oc get ds
NAME              DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE-SELECTOR                AGE
logging-fluentd   5         5         5         5            5           logging-infra-fluentd=true   8m

# oc get pvc
NAME              STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
logging-es-0      Bound     pvc-741c716f-9fa0-11e7-8793-027497ece8ac   50Gi       RWO           gp2            9m
logging-es-1      Bound     pvc-7d0bc3d0-9fa0-11e7-8793-027497ece8ac   50Gi       RWO           gp2            9m
logging-es-2      Bound     pvc-86039fb9-9fa0-11e7-8793-027497ece8ac   50Gi       RWO           gp2            9m
logging-mux-pvc   Bound     pvc-9d812f54-9fa0-11e7-8793-027497ece8ac   30Gi       RWO           gp2            8m

# oc get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                     STORAGECLASS   REASON    AGE
pvc-741c716f-9fa0-11e7-8793-027497ece8ac   50Gi       RWO           Delete          Bound     logging/logging-es-0      gp2                      10m
pvc-7d0bc3d0-9fa0-11e7-8793-027497ece8ac   50Gi       RWO           Delete          Bound     logging/logging-es-1      gp2                      10m
pvc-86039fb9-9fa0-11e7-8793-027497ece8ac   50Gi       RWO           Delete          Bound     logging/logging-es-2      gp2                      9m
pvc-9d812f54-9fa0-11e7-8793-027497ece8ac   30Gi       RWO           Delete          Bound     logging/logging-mux-pvc   gp2                      9m


# POD=logging-es-data-master-39f9joda-1-p2qg2
# oc exec $POD -- curl --connect-timeout 2 -s -k --cert /etc/elasticsearch/secret/admin-cert --key /etc/elasticsearch/secret/admin-key https://logging-es:9200/_cat/indices?v
health status index                                                           pri rep docs.count docs.deleted store.size pri.store.size 
green  open   project.default.7516c4b9-9f95-11e7-ace5-027497ece8ac.2017.09.22   1   0      18099            0     17.1mb         17.1mb 
green  open   .searchguard.logging-es-data-master-j763alrc                      1   2          5            0     91.3kb         30.4kb 
green  open   .kibana                                                           1   0          1            0      3.1kb          3.1kb 
green  open   .searchguard.logging-es-data-master-43lag4ik                      1   2          5            0     91.3kb         30.4kb 
green  open   .searchguard.logging-es-data-master-39f9joda                      1   2          5            0     91.3kb         30.4kb 
green  open   project.logging.fe039967-9f9f-11e7-8793-027497ece8ac.2017.09.22   1   0        711            0    738.1kb        738.1kb 
green  open   .operations.2017.09.22                                            1   0      25688            0       13mb           13mb 

```

If we need to redeplay the logging stack, we can delete logging project and recreate it, and then rerun the above playbook:

```sh
# oc delete project logging
# oadm new-project logging --node-selector=""
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

## docker logs

### journald
Check [docker config for logging](https://docs.docker.com/engine/admin/logging/overview/#supported-logging-drivers):

```sh
# docker info | grep "Logging Driver"
Logging Driver: journald
```

In this case, this is <code>journald</code>.

[Retrieve the container logs](https://docs.docker.com/engine/admin/logging/journald/#retrieving-log-messages-with-journalctl)

```sh
# ssh ip-172-31-5-234.us-west-2.compute.internal
# docker ps | grep frontend-1-pklzq
4ab7d665e371        docker.io/hongkailiu/svt-go@sha256:6b9d8e51c68409d58e925ef4a04b3bb5411a9cd63e360627a7a43ad82c87d691                                   "./svt/svt http"         18 minutes ago      Up 18 minutes                           k8s_helloworldfrontend-1-pklzq_aaa_0d355469-9fa5-11e7-8793-027497ece8ac_0
f8ffed0ff298        registry.ops.openshift.com/openshift3/ose-pod:v3.7.0-0.126.4                                                                          "/usr/bin/pod"           18 minutes ago      Up 18 minutes                           k8s_POD_frontend-1-pklzq_aaa_0d355469-9fa5-11e7-8793-027497ece8ac_0

# #journalctl -b CONTAINER_NAME=<CONTAINER_NAME>

# journalctl -b CONTAINER_NAME=k8s_helloworld_frontend-1-pklzq_aaa_0d355469-9fa5-11e7-8793-027497ece8ac_0
-- Logs begin at Fri 2017-09-22 12:38:05 UTC, end at Fri 2017-09-22 15:04:47 UTC. --
Sep 22 14:48:19 ip-172-31-5-234.us-west-2.compute.internal dockerd-current[11733]: 2017-09-22T14:48:19.780+0000 Debug ▶ DEBU 00
Sep 22 14:56:46 ip-172-31-5-234.us-west-2.compute.internal dockerd-current[11733]: 2017-09-22T14:56:46.245+0000 Info ▶ INFO 002
```

### json-file

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


### json-file without mux
Modify the inv.file:

```
# vi /tmp/inv.file
...
openshift_logging_fluentd_use_journal=false
#openshift_logging_fluentd_read_from_head=false
openshift_logging_use_mux=false
#openshift_logging_mux_client_mode=maximal
openshift_logging_use_ops=false

openshift_logging_fluentd_cpu_limit=1000m
#openshift_logging_mux_cpu_limit=1000m
openshift_logging_kibana_cpu_limit=200m
openshift_logging_kibana_proxy_cpu_limit=100m
openshift_logging_es_memory_limit=9Gi
openshift_logging_fluentd_memory_limit=1Gi
#openshift_logging_mux_memory_limit=2Gi
openshift_logging_kibana_memory_limit=1Gi
openshift_logging_kibana_proxy_memory_limit=256Mi

#openshift_logging_mux_file_buffer_storage_type=pvc
#openshift_logging_mux_file_buffer_pvc_name=logging-mux-pvc
#openshift_logging_mux_file_buffer_pvc_size=30Gi

# oc delete project logging 
project "logging" deleted
# oadm new-project logging --node-selector=""
```

Reset the docker logging driver _on every openshift node_:

```sh
# oc get node
NAME                                          STATUS                     AGE       VERSION
ip-172-31-10-173.us-west-2.compute.internal   Ready                      2h        v1.7.0+80709908fd
ip-172-31-21-185.us-west-2.compute.internal   Ready                      2h        v1.7.0+80709908fd
ip-172-31-23-229.us-west-2.compute.internal   Ready                      2h        v1.7.0+80709908fd
ip-172-31-5-155.us-west-2.compute.internal    Ready,SchedulingDisabled   2h        v1.7.0+80709908fd
ip-172-31-5-234.us-west-2.compute.internal    Ready                      2h        v1.7.0+80709908f

# systemctl stop docker atomic-openshift-node
# vi /etc/sysconfig/docker
...
#OPTIONS=' --selinux-enabled  --log-driver=journald'
OPTIONS=' --selinux-enabled  --log-driver=json-file --log-opt max-size=100M --log-opt max-file=50'
...

# systemctl start docker atomic-openshift-node

```

Run the playbook:

```sh
# ansible-playbook -i /tmp/inv.file openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml
```

Check:
```sh
# #create testing pod as above
# oc get pod -o wide
NAME               READY     STATUS    RESTARTS   AGE       IP            NODE
frontend-1-95lkl   1/1       Running   0          2m        172.20.0.14   ip-172-31-10-173.us-west-2.compute.internal

# curl -H "Content-Type: application/json" -X POST -d '{"line":"abcd"}'
root@ip-172-31-5-155: ~ # curl -H "Content-Type: application/json" -X POST -d '{"line":"111222"}' http://172.20.0.14:8080/logs

# oc logs frontend-1-95lkl
2017-09-22T15:40:01.375+0000 Debug ▶ DEBU 001 [aaa]
2017-09-22T15:47:36.960+0000 Info ▶ INFO 002 [111222]

# ssh ip-172-31-10-173.us-west-2.compute.internal

# #get docker id
# docker ps | grep frontend-1-95lkl
e30921b789b3        docker.io/hongkailiu/svt-go@sha256:6b9d8e51c68409d58e925ef4a04b3bb5411a9cd63e360627a7a43ad82c87d691                                "./svt/svt http"         9 minutes ago       Up 9 minutes                            k8s_helloworld_frontend-1-95lkl_aaa_46a33191-9fac-11e7-8793-027497ece8ac_0
128500d29c61        registry.ops.openshift.com/openshift3/ose-pod:v3.7.0-0.126.4                                                                       "/usr/bin/pod"           9 minutes ago       Up 9 minutes                            k8s_POD_frontend-1-95lkl_aaa_46a33191-9fac-11e7-8793-027497ece8ac_0


# ls -l /var/lib/docker/containers/e30921b789b3*
...
-rw-r-----. 1 root root  278 Sep 22 15:47 e30921b789b39c084ddf8f6eb46fb3741b4500a5d601c628bedb0d9365d6935a-json.log
...

# cat /var/lib/docker/containers/e30921b789b39c084ddf8f6eb46fb3741b4500a5d601c628bedb0d9365d6935a/e30921b789b39c084ddf8f6eb46fb3741b4500a5d601c628bedb0d9365d6935a-json.log 
{"log":"\u001b[36m2017-09-22T15:40:01.375+0000 Debug ▶ DEBU 001\u001b[0m [aaa]\n","stream":"stdout","time":"2017-09-22T15:40:01.376093422Z"}
{"log":"2017-09-22T15:47:36.960+0000 Info ▶ INFO 002\u001b[0m [111222]\n","stream":"stdout","time":"2017-09-22T15:47:36.960742701Z"}

```

## Logging test tool
Check [this](https://github.com/openshift/svt/blob/master/openshift_scalability/content/logtest/ocp_logtest-README.md)
out.

## Reference

[1]. https://medium.com/@yoanis_gil/logging-with-docker-part-1-b23ef1443aac

[2]. http://www.projectatomic.io/blog/2015/04/logging-docker-container-output-to-journald/

[3]. https://www.loggly.com/ultimate-guide/using-journalctl/
