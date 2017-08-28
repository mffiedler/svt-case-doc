# Storage Test

## Doc
* [src](https://github.com/openshift/svt/tree/master/storage)
* [Siva's Demo](https://bluejeans.com/playback/s/BxX2fG6y4ZjAaii8JH1o7on8NfcZj2PV530lLKvyXyjPf3I5oOKQkizb939slYdT)
* [pbench-fio](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-fio.md)

## EBS

### Run

```sh
# vi /etc/origin/master/master-config.yaml
...
projectConfig:
  defaultNodeSelector: ""
...

# systemctl restart atomic-openshift-master

# svt/storage
# #change the hosts in the cluster
# #nodes are compute nodes
# vi config.yaml
# scp id_rsa.pub to svt/storage/id_rsa.pub

# ./start-storage-test.sh
```

check pbench results: [example]()

### Manual clean-up
If error happens and we want to rerun:

```sh
# oc delete project fio-1
# oc delete scc fio
```

## GlusterFS
