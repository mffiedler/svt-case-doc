# Docker Registry

## Doc

* [Deploying a Registry on Existing Clusters](https://docs.openshift.com/container-platform/3.5/install_config/registry/deploy_registry_existing_clusters.html)

## Use filesystem driver for docker-registry

### Check the current setting (Optional)

```sh
# oc exec docker-registry-5-3skdd -- cat /etc/registry/config.yml
```

Note that <code>storage.s3</code> section shows that it uses aws-s3 as storage.

### Create PVC for registry (assumes AWS dynamic provisioning)
Use [registry_pvc.yaml](../files/registry_pvc.yaml): 

```sh
# oc create -f registry_pvc.yaml 
# oc get pvc
# oc get pv
# oc volume deploymentconfigs/docker-registry --add --name=registry-storage -t pvc \
    --claim-name=registry --overwrite -m /registry
```

### Configure docker-registry to use filesystem
Use [registry_secret.yaml](../files/registry_secret.yaml)

```sh
# oc secrets new dockerregistry registry_secret.yaml
# oc volume dc/docker-registry --add --name=dockersecrets -m /etc/registryconfig --type=secret --secret-name=dockerregistry
# oc env dc/docker-registry REGISTRY_CONFIGURATION_PATH=/etc/registryconfig/registry_secret.yaml
```

### Set filesystem threads limit (Optional)
[src](https://github.com/openshift/origin/blob/master/vendor/github.com/docker/distribution/registry/storage/driver/filesystem/driver.go#L24)

```sh
oc env dc/docker-registry REGISTRY_STORAGE_FILESYSTEM_MAXTHREADS=100
```
### Check if the volume is being used
After using docker registry, eg, deployment of pods, run

```sh
# oc exec docker-registry-5-3skdd -- ls /registry                                          
docker

```


## [GlusterFS As docker registery storage](https://github.com/openshift/openshift-ansible/tree/master/playbooks/byo/openshift-glusterfs)

After running the byo playbook:

```sh
$ oc volumes pod docker-registry-1-pth6g
pods/docker-registry-1-pth6g
  pvc/registry-claim (allocated 5GiB) as registry-storage
    mounted at /registry
  secret/registry-certificates as registry-certificates
    mounted at /etc/secrets
  secret/registry-token-4wmf6 as registry-token-4wmf6
    mounted at /var/run/secrets/kubernetes.io/serviceaccount
$ oc get pv -n default 
NAME              CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                    STORAGECLASS   REASON    AGE
registry-volume   5Gi        RWX           Retain          Bound     default/registry-claim                            33m
$ oc get pv
NAME              CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                    STORAGECLASS   REASON    AGE
registry-volume   5Gi        RWX           Retain          Bound     default/registry-claim                            33m

$ oc new-project 
$ oc new-project aaa
$ oc new-app --template=cakephp-mysql-example
$ oc exec -n default docker-registry-1-pth6g -- ls /registry
docker
```
