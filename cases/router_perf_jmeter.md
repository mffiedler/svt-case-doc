# Router Performance Test

Test Case: [OCP-TODO]()

This test is to measure the response time of an JBoss App.

Jenkins job: [SVT_Route_Performance_Test](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/SVT_Route_Performance_Test/).

## Create App with cluster-loader

```sh
# python -u cluster-loader.py -f config/all-quickstarts-no-limits.yaml -v
# oc get project | grep eap64-mysql0
eap64-mysql0                        Active

# oc project eap64-mysql0

# oc get route 
NAME             HOST/PORT                                           PATH      SERVICES         PORT      TERMINATION   WILDCARD
eap-app          eap-app-eap64-mysql0.34.209.136.121.xip.io                    eap-app          <all>                   None
secure-eap-app   secure-eap-app-eap64-mysql0.34.209.136.121.xip.io             secure-eap-app   <all>     passthrough   None


# oc get pod -o wide
NAME                    READY     STATUS      RESTARTS   AGE       IP            NODE
eap-app-1-build         0/1       Completed   0          1m        172.22.0.18   ip-172-31-21-95.us-west-2.compute.internal
eap-app-1-ln7wb         1/1       Running     0          42s       172.20.0.25   ip-172-31-29-79.us-west-2.compute.internal
eap-app-mysql-1-zr1zr   1/1       Running     0          1m        172.20.0.23   ip-172-31-29-79.us-west-2.compute.internal

# #hit route
# curl eap-app-eap64-mysql0.34.209.136.121.xip.io

# #hit pod ip
# curl 172.20.0.25:8080

```
