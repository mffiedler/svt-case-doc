

## check on which node a pod runs

```sh
$ oc get pods -o wide
```

## delete project

```sh
$ for i in {110..119}; do oc delete project "proj$i"; done
```

## delete build

```
$ oc get builds --all-namespaces | grep Fail | grep -E "proj[0-9]+" | while read i; do awk '{system("oc delete build -n " $1 "  " $2)}'; done
```

## create the project

```sh
# python ../../../openshift_scalability/cluster-loader.py -f ../content/conc_builds_nodejs.yaml
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

## authentication

```sh
$ oc whoami
$ oc login -u redhat -p <password>
$ oc login -u system:admin
$ oadm policy add-cluster-role-to-user cluster-admin redhat
```
## new-app

```sh
# oc new-app https://github.com/dev-tool-index/calculator-monitor-docker
```
