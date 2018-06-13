# Grafana

##
 * [grafana.com](https://grafana.com/), [docs.grafana](http://docs.grafana.org/)
 * [grafana@github](https://github.com/grafana/grafana)

## Installation

On an existing OCP cluster:

```sh
$ ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/openshift-grafana/config.yml
```

```sh
# oc get all -n openshift-grafana
NAME                           READY     STATUS    RESTARTS   AGE
pod/grafana-6c5d9d77bd-c6pjd   2/2       Running   0          1m

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/grafana   ClusterIP   172.27.214.94   <none>        443/TCP   1m

NAME                      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/grafana   1         1         1            1           1m

NAME                                 DESIRED   CURRENT   READY     AGE
replicaset.apps/grafana-6c5d9d77bd   1         1         1         1m

NAME                               HOST/PORT                                                PATH      SERVICES   PORT      TERMINATION   WILDCARD
route.route.openshift.io/grafana   grafana-openshift-grafana.apps.0613-ezq.qe.rhcloud.com             grafana    <all>     reencrypt     None

```

Parameters in the playbook: [openshift_grafana](https://github.com/openshift/openshift-ansible/tree/master/roles/openshift_grafana) and [hosts.grafana.example](https://github.com/openshift/openshift-ansible/blob/master/inventory/hosts.grafana.example).

Open `https://grafana-openshift-grafana.apps.0613-ezq.qe.rhcloud.com` with browser and loging with `grafana/grafana`.

Configure grafana to use PVC:

```sh
openshift_grafana_storage_type=pvc
openshift_grafana_sc_name=gp2
grafana_pvc_size=20Gi
```

```sh
# oc get pvc -n openshift-grafana 
NAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
grafana   Bound     pvc-87bf7092-6f1b-11e8-b116-021a0c012f3a   10Gi       RWO            gp2            20m

# oc volumes pod -n openshift-grafana grafana-7dd7b44967-thrhh | grep pvc/grafana -A1
  pvc/grafana (allocated 10GiB) as grafana-data
    mounted at /root/go/src/github.com/grafana/grafana/data in container grafana
``

## Uninstallation

```sh
$ ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/openshift-grafana/uninstall.yml
```
Or,

```sh
# oc delete project openshift-grafana
```
