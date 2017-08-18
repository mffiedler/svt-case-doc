# Quota and Limit

## Doc

* [quota@oc](https://docs.openshift.org/latest/dev_guide/compute_resources.html)

## Quota

### View quotas
Use online starter:

```sh
$ oc login https://api.starter-us-west-2.openshift.com --token=<secret>
$ oc get quota
NAME                          AGE
compute-resources             45d
compute-resources-timebound   45d
object-counts                 45d
```


## Limit

### View limits

```sh
$ oc get limits
NAME              AGE
resource-limits   45d
```
### Resource limit on pods

[Doc](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)
