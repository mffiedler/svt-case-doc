



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
