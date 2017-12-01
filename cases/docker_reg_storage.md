# Storage Test for docker registery

* Push test: Run concurrent build test.
* Pull test: Run scale up/down test.

## PVC backed up by gp2 volume.

Cluster: 1 master, 1 infra, 2 compute nodes where computes are equipped with 300g IOPS (2000) docker device (/dev/sdb).

Set up gp2 PVC as registery storage volume: [steps](../learn/docker_registry.md#use-filesystem-driver-for-docker-registry).

