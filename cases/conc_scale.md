
# Concurrent Scale Test

The concurrent scale test is to verify the ability of Openshift infrastructure to scale out the deployment for apps. It reveals more when checking <code>scale_test.py</code>.

## HA cluster
Basic cluster setup

| role  |  number  |
|---|---|
| master-etcd   |  1 |
| infra  | 1  |
| computing-nodes  | 2  |

## Run the test by Ansible playbooks on a local host (internal)

```sh
$ ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "<master_host>," --private-key ~/.ssh/id_rsa_perf svt/openshift_performance/ci/content/scale_up_complete.yaml
```

There is a [Jenkins job](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/System%20Verification%20Test/job/SVT_App_Scale_Up_Down/) which runs the same playbook.

## Check the generated logs

   - "/tmp/cluster_loader.out"
   - "/tmp/cluster_loader.err"
   - "/tmp/check_app.out"
   - "/tmp/check_app.err"
   - "/tmp/scale_test.out"
   - "/tmp/scale_test.err"
 
 
