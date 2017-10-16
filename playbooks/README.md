# Playbooks

## nfs
The playbook will start an nfs server which is backed up by an oc service.

```sh
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "${MASTER_HOSTNAME}," --private-key ./id_rsa_perf ./nfs_via_pod.yml
```

## clean docker images on computing nodes
Run on master
```sh
# ../scripts/cat_nodes.sh > /tmp/inv.file
# #change the keyword of docker images in ./clean_docker_images.yml if needed
# ansible-playbook -i /tmp/inv.file  ./clean_docker_images.yml -v
```

## pbench
TODO

## launch device-mapper module

```sh
$ ansible-playbook -i inv.file playbooks/dm_thin_pool.yml
```