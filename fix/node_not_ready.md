# Node NOT Ready

In containerized environment, sometimes <code>oc get nodes</code> shows that all nodes are not ready.

## Cause
The cause is that it timed out when installation playbook restart <code>atomic-openshift-master.service</code>.

## Error logs
Not sure if it is related. But when we run the commands to fix the issue, such logs are gone.

```sh
# journalctl -u atomic-openshift-node.service
Jul 20 09:01:06 ip-172-31-42-144.us-west-2.compute.internal systemd[1]: atomic-openshift-node.service: main process exited, code=exited, status=255/n/a
Jul 20 09:01:06 ip-172-31-42-144.us-west-2.compute.internal atomic-openshift-node[51294]: Error response from daemon: No such container: atomic-openshift-node
Jul 20 09:01:06 ip-172-31-42-144.us-west-2.compute.internal systemd[1]: atomic-openshift-node.service: control process exited, code=exited status=1
Jul 20 09:01:06 ip-172-31-42-144.us-west-2.compute.internal systemd[1]: Unit atomic-openshift-node.service entered failed state.
Jul 20 09:01:06 ip-172-31-42-144.us-west-2.compute.internal systemd[1]: atomic-openshift-node.service failed.
Jul 20 09:01:11 ip-172-31-42-144.us-west-2.compute.internal systemd[1]: atomic-openshift-node.service holdoff time over, scheduling restart.
```

## Fix
This can be fixed by:

```sh
# systemctl status atomic-openshift-node.service docker
# systemctl stop atomic-openshift-node.service docker
# systemctl start atomic-openshift-node.service docker
# systemctl status atomic-openshift-node.service docker
```
