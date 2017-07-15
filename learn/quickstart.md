## Quickstart

### [Steps](https://docs.openshift.org/latest/getting_started/developers_cli.html)

### Dataflow

source -> build -> image -> deploy -> pod -> service -> route -> scale/update ...

Pods is the core and what OC runs for your application.

#### [Build from image](https://docs.openshift.org/latest/dev_guide/application_lifecycle/new_app.html#specifying-an-image)

```sh
# oc new-app docker.io/library/jenkins:2.46.3
```

What objects are created by the above command?

```sh
# oc get all
NAME         DOCKER REPO                                    TAGS      UPDATED
is/jenkins   docker-registry.default.svc:5000/aaa/jenkins   2.46.3    3 minutes ago

NAME         REVISION   DESIRED   CURRENT   TRIGGERED BY
dc/jenkins   1          1         1         config,image(jenkins:2.46.3)

NAME           DESIRED   CURRENT   READY     AGE
rc/jenkins-1   1         1         1         3m

NAME          CLUSTER-IP       EXTERNAL-IP   PORT(S)              AGE
svc/jenkins   172.25.168.179   <none>        8080/TCP,50000/TCP   3m

NAME                 READY     STATUS    RESTARTS   AGE
po/jenkins-1-zpxnp   1/1       Running   0          3m
```

Can we do it directly? Or more precisely, can we manipulate those objects directly?

Yes, See [template](template.md).

