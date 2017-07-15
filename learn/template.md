## [Templates](https://docs.openshift.org/latest/dev_guide/templates.html#dev-guide-templates)

### Get objects of a project

```sh
# oc get all -o yaml > aaa.items.yaml
```

See [aaa.items.yaml](aaa.items.yaml).

The file is very close to [OC template](https://docs.openshift.org/latest/dev_guide/templates.html#dev-guide-templates).

### [Export template from project](https://docs.openshift.org/latest/dev_guide/templates.html#export-as-template)


```sh
# oc export all --as-template=aaa-project-template > aaa.project.template.yaml
```

See [aaa.project.template.yaml](aaa.project.template.yaml).

### Read the template

#### Object kind

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

#### Recreate the objects via template

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


### Modify the template file

It has been shown above that we can achieve the same using <code>template</code> instead of <code>new-app</code> command.




It is stated in [K8S doc](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) that dc is a referred way to deploy an app.

###
