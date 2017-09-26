# App Performance Test

Test Case: [OCP-9188](https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-9188)

This test is to measure the response time of an JBoss App (or other Apps) via route.

Jenkins job: [SVT_Application_Performance_Test](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/SVT_Application_Performance_Test/).

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

# #hit route
# curl eap-app-eap64-mysql0.34.209.136.121.xip.io


```

## Edit config
Since the pod's IP is accessible only from the cluster, we run it on master:

```sh
# #change other jmeter params as the case requires
# #comment out Apps which are not under test
# vi osperf/src/main/config/jmeter/JmeterTestConfig_appperf.yaml
...
   - testSuiteName: jbosseap
     appURL: http://eap-app-eap64-mysql0.34.209.136.121.xip.io
...

# mv osperf/src/main/config/jmeter/JmeterTestConfig_appperf.yaml osperf/src/main/config/jmeter/JmeterTestConfig.yaml
```

## Run tests

```sh
# cd svt/application_performance/osperf
# mvn verify

```

## Check results
[Example]()
