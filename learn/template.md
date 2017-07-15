## [Templates](https://docs.openshift.org/latest/dev_guide/templates.html#dev-guide-templates)

### Get objects of a project

```sh
# oc get pods -o yaml > aaa.items.yaml
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

*Only to this point the yaml contents of the objects in the ducuments start to make sense.*

All those objects above created automatically when we create a new app by one oc command in [quickstart](quickstart.md):


```sh
# oc new-app docker.io/library/jenkins:2.46.3
```


### Modify the template file

Achieve the same using <code>template</code> instead of <code>new-app</code> command.

###
