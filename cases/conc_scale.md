
# Concurrent Scale Test

The concurrent scale test is to verify the ability of Openshift infrastructure to scale out the deployment for apps.

## HA cluster
Basic cluster setup

| role  |  number  |
|---|---|
| master-etcd   |  1 |
| infra  | 1  |
| computing-nodes  | 2  |

## Run the test by Ansible playbooks

```sh
$ ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "ec2-54-200-142-84.us-west-2.compute.amazonaws.com," --private-key ~/.ssh/id_rsa_perf svt/openshift_performance/ci/content/scale_up_complete.yaml
```
