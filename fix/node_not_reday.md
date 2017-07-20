# Node NOT Ready

In containerized environment, sometimes <code>oc get nodes</code> shows that all nodes are not ready.

## Cause
The cause is that it timed out when installation playbook restart <code>atomic-openshift-master.service</code>.

## Fix
This can be fixed by:

```sh
# systemctl status atomic-openshift-node.service docker
# systemctl stop atomic-openshift-node.service docker
# systemctl start atomic-openshift-node.service docker
# systemctl status atomic-openshift-node.service docker
```
