# App Test on OCP: Jenkins

## Deploy Jenkins on OCP

Choose template:

```sh
# oc get template -n openshift | grep jenkins
jenkins-ephemeral                               Jenkins service, without persistent storage....                                    6 (all set)       6
jenkins-persistent                              Jenkins service, with persistent storage....                                       7 (all set)       7

# oc process --parameters -n openshift jenkins-persistent
NAME                       DESCRIPTION                                                                                                                             GENERATOR           VALUE
JENKINS_SERVICE_NAME       The name of the OpenShift Service exposed for the Jenkins container.                                                                                        jenkins
JNLP_SERVICE_NAME          The name of the service used for master/slave communication.                                                                                                jenkins-jnlp
ENABLE_OAUTH               Whether to enable OAuth OpenShift integration. If false, the static account 'admin' will be initialized with the password 'password'.                       true
MEMORY_LIMIT               Maximum amount of memory the container can use.                                                                                                             512Mi
VOLUME_CAPACITY            Volume space available for data, e.g. 512Mi, 2Gi.                                                                                                           1Gi
NAMESPACE                  The OpenShift Namespace where the Jenkins ImageStream resides.                                                                                              openshift
JENKINS_IMAGE_STREAM_TAG   Name of the ImageStreamTag to be used for the Jenkins image.                                                                                                jenkins:2

# oc new-project ttt
### the default value "jenkins:2" does not work yet
# oc new-app --template=jenkins-persistent -p ENABLE_OAUTH=false -p MEMORY_LIMIT=4096Mi -p VOLUME_CAPACITY=1000Gi -p JENKINS_IMAGE_STREAM_TAG=jenkins:1
### OR storage class is added in this template:
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/jenkins-persistent-ttt.yaml -p ENABLE_OAUTH=false -p MEMORY_LIMIT=4096Mi -p VOLUME_CAPACITY=100Gi -p JENKINS_IMAGE_STREAM_TAG=jenkins:1 -p STORAGE_CLASS_NAME=glusterfs-storage | oc create -f -

# oc get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
jenkins   Bound     pvc-2408e906-31d1-11e8-8ee3-02933b6e762a   10Gi       RWO            gp2            26m

# oc volumes pod jenkins-1-hfjsv
pods/jenkins-1-hfjsv
  pvc/jenkins (allocated 10GiB) as jenkins-data
    mounted at /var/lib/jenkins
  secret/jenkins-token-9wxwd as jenkins-token-9wxwd
    mounted at /var/run/secrets/kubernetes.io/serviceaccount

# oc get route
NAME      HOST/PORT                                  PATH      SERVICES   PORT      TERMINATION     WILDCARD
jenkins   jenkins-ttt.apps.0327-nbn.qe.rhcloud.com             jenkins    <all>     edge/Redirect   None

### brower with url: jenkins-ttt.apps.0327-nbn.qe.rhcloud.com; admin/password
```

```sh
# oc patch -n ttt deploymentconfigs/jenkins --patch '{"spec": {"template": {"spec": {"nodeSelector": {"aaa": "bbb"}}}}}'
```

## Set up jobs with JJB

See [jjb.md](../learn/jjb.md) for details.

```sh
### jjb write cache files and thus need to create a PVC for writing
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p PVC_NAME=jjb-pvc -p STORAGE_CLASS_NAME=gp2 | oc create -f -
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/cm_jjb_template.yaml -p JENKINS_URL=https://$(oc get route -n ttt --no-headers | awk '{print $2}') | oc create -f -
### XDG_CACHE_HOME: ref. https://github.com/openstack-infra/jenkins-job-builder/blob/master/jenkins_jobs/cache.py#L80
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/dc_jjb.yaml

# oc exec -n ttt $(oc get pod -n ttt | grep jjb | awk '{print $1}') -- curl -L -o /data/download_job_files.sh https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/download_job_files.sh
# oc exec -n ttt $(oc get pod -n ttt | grep jjb | awk '{print $1}') -- bash /data/download_job_files.sh
# oc exec -n ttt $(oc get pod -n ttt | grep jjb | awk '{print $1}') -- jenkins-jobs --flush-cache  update --delete-old /data
```

## Run Jenkins jobs

Trigger a job via rest api

```sh
### ref. https://wiki.jenkins.io/display/JENKINS/Remote+access+API
$ curl -k --user admin:password -X POST https://$(oc get route -n ttt --no-headers | awk '{print $2}')/job/test_job/build --data-urlencode json='{"parameter": []}'
```

Get a build result via rest api

```sh
### ref. https://serverfault.com/questions/309848/how-to-check-the-build-status-of-a-jenkins-build-from-the-command-line
$ curl -s -k --user admin:password https://$(oc get route -n ttt --no-headers | awk '{print $2}')/job/test_job/1/api/json | jq '.result'
"SUCCESS"

### Get the last build:
$ curl -s -k --user admin:password https://$(oc get route -n ttt --no-headers | awk '{print $2}')/job/test_job/lastBuild/api/json?pretty=true

```
