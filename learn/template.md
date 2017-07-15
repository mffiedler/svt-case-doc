## [Templates](https://docs.openshift.org/latest/dev_guide/templates.html#dev-guide-templates)

### Get objects of a project

```sh
# oc get pods -o yaml > aaa.items.yaml
```

See [aaa.items.yaml](aaa.items.yaml).

The file is very close to [OC template](https://docs.openshift.org/latest/dev_guide/templates.html#dev-guide-templates).

### [Export template from project](https://docs.openshift.org/latest/dev_guide/templates.html#export-as-template)


```sh
# oc export all --as-template=aaa_project_template > aaa.project.template.yaml
```

See [aaa.project.template.yaml](aaa.project.template.yaml).

### Read the template

#### object kind is the starting points

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

### Modify the template file

###
