# [Helm](https://helm.sh/)

## Installation

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

[Helm on OCP](https://blog.openshift.com/getting-started-helm-openshift/)

```sh
# export TILLER_NAMESPACE=tiller
# oc new-project tiller
# oc project tiller
# curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.10.0-linux-amd64.tar.gz
# tar -zxvf helm-v2.10.0-linux-amd64.tar.gz 
# cd linux-amd64/
# ./helm init --client-only
# oc process -f https://github.com/openshift/origin/raw/master/examples/helm/tiller-template.yaml -p TILLER_NAMESPACE="${TILLER_NAMESPACE}" -p HELM_VERSION=v2.10.0 | oc create -f -
# oc rollout status deployment tiller
# oc get all
NAME                          READY     STATUS    RESTARTS   AGE
pod/tiller-84786b45c4-jltpb   1/1       Running   0          3m

NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/tiller   1         1         1            1           3m

NAME                                DESIRED   CURRENT   READY     AGE
replicaset.apps/tiller-84786b45c4   1         1         1         3m

# ./helm version
Client: &version.Version{SemVer:"v2.10.0", GitCommit:"9ad53aac42165a5fadc6c87be0dea6b115f93090", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.10.0", GitCommit:"9ad53aac42165a5fadc6c87be0dea6b115f93090", GitTreeState:"clean"}


```

## [Use helm](https://docs.helm.sh/using_helm/#using-helm)

[Create a helm chart](https://docs.helm.sh/using_helm/#creating-your-own-charts):

```
### if stable folder is not there yet
# mkdir stable
# helm create stable/svt-go
# tree .
.
|-- README.md
`-- stable
    `-- svt-go
        |-- charts
        |-- Chart.yaml
        |-- templates
        |   |-- deployment.yaml
        |   |-- _helpers.tpl
        |   |-- ingress.yaml
        |   |-- NOTES.txt
        |   `-- service.yaml
        `-- values.yaml

4 directories, 8 files

# helm lint stable/svt-go/
```

Edit the above files for your chart, and we can push it into git repo.

Roll out a release for an existing chart:

```sh
# git clone https://github.com/hongkailiu/charts.git
# cd charts/
# helm install stable/svt-go/

# helm list
NAME          	REVISION	UPDATED                 	STATUS  	CHART       	APP VERSION	NAMESPACE
errant-buffalo	1       	Wed Sep  5 21:23:39 2018	DEPLOYED	svt-go-0.1.0	0.2.1      	ttt
root@ip-172-31-0-220: ~/charts # oc get all
NAME                                READY     STATUS    RESTARTS   AGE
pod/errant-buffalo-svt-go-1-ffqsd   1/1       Running   0          4m

NAME                                            DESIRED   CURRENT   READY     AGE
replicationcontroller/errant-buffalo-svt-go-1   1         1         1         4m

NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/errant-buffalo-svt-go   ClusterIP   172.25.154.146   <none>        8080/TCP   4m

NAME                                                       REVISION   DESIRED   CURRENT   TRIGGERED BY
deploymentconfig.apps.openshift.io/errant-buffalo-svt-go   1          1         1         config

NAME                           HOST/PORT                         PATH      SERVICES                PORT      TERMINATION   WILDCARD
route.route.openshift.io/web   web-ttt.apps.54.190.39.0.xip.io             errant-buffalo-svt-go   8080                    None
root@ip-172-31-0-220: ~/charts # curl web-ttt.apps.54.190.39.0.xip.io
{"version":"0.0.1","ips":["127.0.0.1","::1","172.20.0.34","fe80::30bd:2aff:fe81:ab19"],"now":"2018-09-05T21:28:31.220185921Z"}


### delete a release
# helm delete errant-buffalo
```

TODO
* helm repo: using my own repo
* hooks