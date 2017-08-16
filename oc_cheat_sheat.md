
## [journalctl](https://www.loggly.com/ultimate-guide/using-journalctl/)

```sh
# systemctl list-unit-files --all
# journalctl -u atomic-openshift-node.service
```

## authentication

```sh
$ oc whoami
$ oc login -u redhat -p <password>
$ oc login -u system:admin
$ oadm policy add-cluster-role-to-user cluster-admin redhat
```

## check on which node a pod runs

```sh
$ oc get pods -o wide
```

## delete project

```sh
$ oc delete project -l purpose=test
$ for i in {110..119}; do oc delete project "proj$i"; done
$ oc get projects | cut -f1 -d" " | grep -E "proj[0-9]+" | while read i; do oc delete project $i; done
```

## delete build

```
$ oc get builds --all-namespaces | grep Fail | grep -E "proj[0-9]+" | while read i; do awk '{system("oc delete build -n " $1 "  " $2)}'; done
```

## remove a computing node from cluster

  - on the computing node

  ```sh
  # systemctl stop atomic-openshift-node
  # systemctl disable atomic-openshift-node
  ```

  - on a master node

  ```sh
  # oc get nodes
  # oc delete node <node_name>
  ```
## restart ectd

```sh
# systemctl restart etcd
```

## get log from container in pod

```sh
$ oc logs <pod_name> -c kibana --loglevel=10
```

## get all objects of a project

```sh
$ oc project <project_name>
$ oc get all
```

## new-app

```sh
# oc new-app https://github.com/dev-tool-index/calculator-monitor-docker
```

## config and restart master

```sh
# vi /etc/origin/master/master-config.yaml
# systemctl restart atomic-openshift-master
```


