# Docker Registry

## Doc

* [Deploying a Registry on Existing Clusters](https://docs.openshift.com/container-platform/3.5/install_config/registry/deploy_registry_existing_clusters.html)

## Use filesystem driver for docker-registry

### Create PVC for registry (assumes AWS dynamic provisioning)
Use [registry_pvc.yaml](../files/registry_pvc.yaml): 

```sh
# oc create -f registry_pvc.yaml 
# oc get pvc
# oc volume deploymentconfigs/docker-registry --add --name=registry-storage -t pvc --claim-name=registry --overwrite
```

### Configure docker-registry to use filesystem

```sh
# vi /root/config.yml:
version: 0.1
log:
  level: debug
http:
  addr: :5000
storage:
  delete:
    enabled: true
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /registry
auth:
  openshift:
    realm: openshift
middleware:
  registry:
  - name: openshift
  repository:
  - name: openshift
    options:
      pullthrough: True
      acceptschema2: False
      enforcequota: False
  storage:
  - name: openshift

# oc secrets new dockerregistry /root/config.yml
# oc volume dc/docker-registry --add --name=dockersecrets -m /etc/registryconfig --type=secret --secret-name=dockerregistry
# oc env dc/docker-registry REGISTRY_CONFIGURATION_PATH=/etc/registryconfig/config.yml
```

### Set filesystem threads limit (Optional)

```sh
oc env dc/docker-registry REGISTRY_STORAGE_FILESYSTEM_MAXTHREADS=150
```
