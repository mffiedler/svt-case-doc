# [Helm](https://helm.sh/)

## Installation

[Helm on OCP](https://blog.openshift.com/getting-started-helm-openshift/)

[Client](https://docs.helm.sh/using_helm/#installing-helm):

```sh
$ curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.9.0-rc3-linux-amd64.tar.gz
$ tar -zxvf helm-v2.9.0-rc3-linux-amd64.tar.gz
$ cd bin/
$ ln -s ../linux-amd64/helm helm
```

Server:

```sh
$ oc new-project tiller
$ helm init --tiller-namespace tiller
$ oc get all
NAME                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/tiller-deploy   1         1         1            1           41s

NAME                          DESIRED   CURRENT   READY     AGE
rs/tiller-deploy-574d6688bc   1         1         1         41s

NAME                                READY     STATUS    RESTARTS   AGE
po/tiller-deploy-574d6688bc-27phh   1/1       Running   0          41s

NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)     AGE
svc/tiller-deploy   ClusterIP   172.26.49.79   <none>        44134/TCP   41s

$ helm version --tiller-namespace tiller
Client: &version.Version{SemVer:"v2.9.0-rc3", GitCommit:"60abcdca41f544caaecb224acbfb92aee11e1f6e", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.9.0-rc3", GitCommit:"60abcdca41f544caaecb224acbfb92aee11e1f6e", GitTreeState:"clean"}

```

TODO https://docs.helm.sh/using_helm/#using-helm
