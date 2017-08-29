# Storage Test
This test is to run (via ssh) fio command in a CentOS pod on pbench remote node and send pbench-results to pbench server. 

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

check pbench results: [example](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-24-235/).

### Manual clean-up
If error happens and we want to rerun:

```sh
# oc delete project fio-1
# oc delete scc fio
# #might also need to kill pbench processes manually including pbench remote nodes
# ps -ef | grep fio | grep pbench | awk '{print $2}' | xargs kill -9
```

## GlusterFS
