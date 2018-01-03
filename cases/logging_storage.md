# Storage Test for Logging Stack

## Test env.

### IO1
Follow [Case OCP-15841](https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-15841).

1 master, 1 infra and 2 computes.

### Glusterfs

## Configure default storage class

### IO1

```sh
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/sc_io1.yaml
# oc get sc
NAME            PROVISIONER             AGE
gp2             kubernetes.io/aws-ebs   23h
io1 (default)   kubernetes.io/aws-ebs   22h

```

### Glusterfs

#### Install CNS

## Check docker configuration

```sh
### Check docker configuration file on each node
# cat /etc/sysconfig/docker
...
OPTIONS='--selinux-enabled --log-opt max-size=10M --log-opt max-file=3 --signature-verification=false'
...

### Restart docker and atomic-openshift-node services if we need to modify the above file
```


## Deploy logging stack

Set up buffer size limit for fluentd:

```
openshift_logging_fluentd_buffer_size_limit=16m
```

After running logging playbook, make sure only primary nodes are labeled for fluentd:

```sh
oc label node --all logging-infra-fluentd-
oc label node -l region=primary logging-infra-fluentd=true
```

Move es pod to infra:

```sh
# oc edit dc logging-es-data-master-xxxxx
     dnsPolicy: ClusterFirst
     nodeSelector:
        region: infra
        zone: default

```

Set the elasticsearch threadpool bulk queue size to 200:

```sh
# POD=logging-es-data-master-hye5503q-1-g4w27
# oc exec -n logging $POD -- curl --connect-timeout 2 -s -k --cert /etc/elasticsearch/secret/admin-cert --key /etc/elasticsearch/secret/admin-key -XPUT https://localhost:9200/_cluster/settings -d '{"persistent" : {"threadpool.bulk.queue_size" : 200}}'
# oc exec $POD -- curl -s -k --cert /etc/elasticsearch/secret/admin-cert --key /etc/elasticsearch/secret/admin-key https://localhost:9200/_cluster/settings | python -mjson.tool
```