# CNS: Usability Test

## heketi pod can survive of node-draining

Label 2 nodes with `heketi=heketi` which is the node selector for
`dc/heketi-storage`.

Then create 300 pods with glusterfs PVCs which usually takes about 30 mins.
During the creation, drain the node where heketi is running.

Expected result: 300 pods in running state.

Extra work on the case: no

## No impact on pods when one of glusterfs pods get restarted

10 pods with glusterfs PVCs and the pods write logs onto files on PVCs.

Restart glusterfs pod one after another with a reasonable interval: drain
node or delete pod or remove label `glusterfs=storage-host` on the
glusterfs node which is the node selector for ds/glusterfs-storage.

Expected result: all logs are fine with correct content.

Extra work on the case: Need to implement the logic with Mike's logging
tool or start from scratch.