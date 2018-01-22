# Build

## S2I
When we do <code>oc new-app</code> command, there is a way to specify the base image of the built image: Check [the doc](https://docs.openshift.com/container-platform/3.7/dev_guide/application_lifecycle/new_app.html#specifying-source-code).

```
$ oc new-app openshift/ruby-20-centos7:latest~/home/user/code/my-ruby-app
```

If not specified, then openshift has its own magic to choose a right base image.

Dig a big further with that command:

```sh
### The search result depends on stored items on the server
### This is done on 3.9
# oc new-app --search eap | grep eap64-basic-s2i -A2
eap64-basic-s2i
  Project: openshift
  An example EAP 6 application. For more information about using this template, see https://github.com/jboss-openshift/application-templates.

### Create an app based on that template
# oc new-app --template=eap64-basic-s2i

```

Several useful information from the output of the above command:

* Template src: https://github.com/jboss-openshift/application-templates
* about EAP app: https://github.com/jboss-developer/jboss-eap-quickstarts

```sh
# oc get bc -o yaml | grep "from:" -A 3
        from:
          kind: ImageStreamTag
          name: jboss-eap64-openshift:1.6
          namespace: openshift

# oc get is -n openshift jboss-eap64-openshift -o yaml | grep "tag: \"1.6" -B3
      dockerImageReference: registry.access.redhat.com/jboss-eap-6/eap64-openshift@sha256:03416282b034b93614ab2af74441ce481226bcf0b0b6c614cacd1b6f008f9792
      generation: 2
      image: sha256:03416282b034b93614ab2af74441ce481226bcf0b0b6c614cacd1b6f008f9792
    tag: "1.6"

```

So we found it: https://access.redhat.com/containers/?tab=tags#/registry.access.redhat.com/jboss-eap-6/eap64-openshift

```sh
# docker pull registry.access.redhat.com/jboss-eap-6/eap64-openshift:1.6
```

More candidates of base image for your J2EE apps are [here](https://github.com/jboss-openshift/application-templates#common-image-repositories):

```sh
# curl -L https://raw.githubusercontent.com/jboss-openshift/application-templates/master/jboss-image-streams.json | grep from  -A2
...
registry.access.redhat.com/jboss-webserver-3/webserver30-tomcat7-openshift:1.3
...
```

TODO: 

* How is this above base image built: buildah or Dockerfile?
* Are they better than the frabric8 images mentioned here? https://developers.redhat.com/blog/2017/03/14/java-inside-docker/
* How to config jave/jboss options when starting the pod?
* What is the overhead for an app, wrapped up by a docker container?


