# Build

## S2I
When we <code>oc new-app</code> command, there is a way to specify the base image of the built image: Check [the doc](https://docs.openshift.com/container-platform/3.7/dev_guide/application_lifecycle/new_app.html#specifying-source-code).

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

So ... the docker images used by the template ... it gives clues [here](https://github.com/jboss-openshift/application-templates#common-image-repositories). Here is the idea:

```sh
# curl -L https://raw.githubusercontent.com/jboss-openshift/application-templates/master/jboss-image-streams.json | grep from  -A2
...
registry.access.redhat.com/jboss-webserver-3/webserver30-tomcat7-openshift:1.3
...
```

Those could be candidates of base image for your J2EE apps.

TODO: 

* Can we get the hard proof of which the base image is for a build output?
* Are they better than the frabric8 images mentioned here? https://developers.redhat.com/blog/2017/03/14/java-inside-docker/
* What is the overhead for an app, wrapped up by a docker container?


