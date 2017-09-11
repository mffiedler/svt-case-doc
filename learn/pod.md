# Pod

## [Readiness and liveness](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)

```sh
# oc get pod heketi-storage-2-dwsn5 -o yaml | grep -i nessProbe -A 9
    livenessProbe:
      failureThreshold: 3
      httpGet:
        path: /hello
        port: 8080
        scheme: HTTP
      initialDelaySeconds: 30
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 3
--
    readinessProbe:
      failureThreshold: 3
      httpGet:
        path: /hello
        port: 8080
        scheme: HTTP
      initialDelaySeconds: 3
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 3

```
