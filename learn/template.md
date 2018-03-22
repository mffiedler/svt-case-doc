# [Templates](https://docs.openshift.org/latest/dev_guide/templates.html#dev-guide-templates)

## Get objects of a project

```sh
# oc get all -o yaml
```

The output can be used as input for <code>oc create</code> command.

## [Export template from project](https://docs.openshift.org/latest/dev_guide/templates.html#export-as-template)


```sh
# oc export all --as-template=aaa-project-template > aaa.project.template.yaml
```

See [aaa.project.template.yaml](../files/aaa.project.template.yaml).

## Read the template

### Object kind

FInd object kind and find them in K8S and OC documents.

```sh
# grep "kind:" aaa.project.template.yaml 
kind: Template
  kind: ImageStream
        kind: DockerImage
  kind: DeploymentConfig
          kind: ImageStreamTag
  kind: ReplicationController
      kind: DeploymentConfig
  kind: Service
  kind: Pod
      kind: ReplicationController
```

*Only to this point the yaml contents of the objects in the ducuments start to make sense to me.*

All those objects above created automatically when we create a new app by one oc command in [quickstart](quickstart.md):


```sh
# oc new-app docker.io/library/jenkins:2.46.3
```

### Recreate the objects via template

```sh
# oc process -f aaa.project.template.yaml | oc create -f -
# oc get all
NAME         DOCKER REPO                                    TAGS      UPDATED
is/jenkins   docker-registry.default.svc:5000/aaa/jenkins   2.46.3    

NAME         REVISION   DESIRED   CURRENT   TRIGGERED BY
dc/jenkins   0          1         0         config,image(jenkins:2.46.3)

NAME          CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
svc/jenkins   172.26.113.20   <none>        8080/TCP,50000/TCP   5m
```

*Note that* our rs and po are missing. Our app is not deployed and hence not running. The reason is that <code>dc/jenkins</code> is configured with triggers when we use <code>new-app</code> command to generate those objects. When you try to <code>rollout</code> them manually, it does not work either.

```sh
root@ip-172-31-7-124: ~ # oc rollout latest dc/jenkins
Error from server (BadRequest): cannot trigger a deployment for "jenkins" because it contains unresolved images
```

Let us remove the triggers and try again

```sh
# oc set triggers dc/jenkins --remove-all 
deploymentconfig "jenkins" updated
root@ip-172-31-7-124: ~ # oc rollout latest dc/jenkins
deploymentconfig "jenkins" rolled out
root@ip-172-31-7-124: ~ # oc get all
NAME         DOCKER REPO                                    TAGS      UPDATED
is/jenkins   docker-registry.default.svc:5000/aaa/jenkins   2.46.3    

NAME         REVISION   DESIRED   CURRENT   TRIGGERED BY
dc/jenkins   1          1         1         

NAME           DESIRED   CURRENT   READY     AGE
rc/jenkins-1   1         1         1         15m

NAME          CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
svc/jenkins   172.26.113.20   <none>        8080/TCP,50000/TCP   1h

NAME                 READY     STATUS    RESTARTS   AGE
po/jenkins-1-81636   1/1       Running   0          15m
```

*Note that* rolling out dc results to creating rc and po.


## Modify the template file

It has been shown above that we can achieve the same using <code>template</code> instead of <code>new-app</code> command.

It is stated in [K8S doc](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) that dc is a referred way to deploy an app.

Assume that we want to create rc directly.

```sh
# oc export -o json rc --as-template=aaa-rc-json > aaa.rc.template.json
# oc process -f aaa.rc.template.json | oc create -f -
```

However, it does *not* create rc. I guess (did fiind supporting doc) it has dependency on the dc. Start to lean up sections. Then rc is created successfully via [aaa.rc.template.json](aaa.rc.template.json).

*Note that* the value docker image is _jenkins:2.46.3_. It does not work (pull image failure) if _docker.io/library/jenkins:2.46.3_. Maybe for library it has too be like that. (July 15, 2017)

## Parameterized template

The last section <code>parameters</code> in [aaa.rc.template.json](../files/aaa.rc.template.json) is added manually. It gives the default value of variables in the templates. We can also use [oc command args](https://docs.openshift.org/latest/dev_guide/templates.html#templates-parameters) to override them.


## SVT

[SVT](https://github.com/openshift/svt), specially the cluster loader, uses every often templates to create oc objects.

## Understand the templates shipped with openshift

```sh
$ oc get template -n openshift
```

For example, dig into `postgresql-persistent`:

```
### List parameters in the template:
$ oc process --parameters -n openshift postgresql-persistent
$ oc get template postgresql-persistent -n openshift  -o yaml | grep "image:"
          image: ' '

```

What is the image used in the dc? Let's see:

```sh
$ oc new-project ttt
$ oc new-app --template=postgresql-persistent
$ oc get deploymentconfigs/postgresql -o json | jq '.spec.triggers[0]'
  {
    "imageChangeParams": {
      "automatic": true,
      "containerNames": [
        "postgresql"
      ],
      "from": {
        "kind": "ImageStreamTag",
        "name": "postgresql:9.6",
        "namespace": "openshift"
      },
      "lastTriggeredImage": "registry.access.redhat.com/rhscl/postgresql-96-rhel7@sha256:06b86e301a272c1861571e1c514d3f71f7a1bd0f4cbc283b352bb6c5a34b62ec"
    },
    "type": "ImageChange"
  }
```

So the dc is [triggered](https://docs.openshift.com/container-platform/3.7/dev_guide/deployments/basic_deployment_operations.html#image-change-trigger) by `ImageStreamTag` named `postgresql:9.6` in `openshift`:

```sh
$ oc get ImageStreamTag -n openshift postgresql:9.6 -o json | jq '.image.dockerImageReference'
"registry.access.redhat.com/rhscl/postgresql-96-rhel7@sha256:06b86e301a272c1861571e1c514d3f71f7a1bd0f4cbc283b352bb6c5a34b62ec"
```

They totally match!