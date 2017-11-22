# Missing "openshift3/ose-deployer" Image

## Problem description

After installation of OC cluster via flexy build, we get

```sh
# oc get pod -n default
NAME                        READY     STATUS             RESTARTS   AGE
docker-registry-1-deploy    0/1       ImagePullBackOff   0          1h
registry-console-1-deploy   0/1       ImagePullBackOff   0          1h
router-1-deploy             0/1       ImagePullBackOff   0          1h

# oc describe pod docker-registry-1-deploy -n default
...
  2m		57s		4	kubelet, ip-172-31-41-136.us-west-2.compute.internal	spec.containers{deployment}	Warning		Failed			Failed to pull image "registry.reg-aws.openshift.com:443/openshift3/ose-deployer:v3.7.9": rpc error: code = 2 desc = Error: image openshift3/ose-deployer:v3.7.9 not found
...

# docker pull registry.reg-aws.openshift.com:443/openshift3/ose-deployer:v3.7.9
Trying to pull repository registry.reg-aws.openshift.com:443/openshift3/ose-deployer ...
Pulling repository registry.reg-aws.openshift.com:443/openshift3/ose-deployer
Error: image openshift3/ose-deployer:v3.7.9 not found
```

Double check

```sh
[hongkliu@hongkliu svt-case-doc]$ oc get is -n openshift3 ose-deployer -o yaml | grep "tag:" | cut -f2 -d":" | sort -V
...
 v3.7.7-1
 v3.7.9-1
```

So image registry.reg-aws.openshift.com:443/openshift3/ose-deployer:v3.7.9 is not there. The cause could be [a bug](https://bugzilla.redhat.com/show_bug.cgi?id=1508563).

## Control version of ose-deployer image
The version is configured on master:

```sh
# grep format /etc/origin/master/master-config.yaml -B1
imageConfig:
  format: registry.reg-aws.openshift.com:443/openshift3/ose-${component}:${version}
```

Modify it with <code>format: registry.reg-aws.openshift.com:443/openshift3/ose-${component}:v3.7.9-1</code>
and then

```sh
# systemctl status atomic-openshift-master*
```

Edit DCs to deploy the components with the desired version, eg,

```sh
# oc edit deploymentconfigs/registry-console
```

## Control version with Ansible variables during installation

```
oreg_url=registry.reg-aws.openshift.com:443/openshift3/ose-${component}:v3.7.9-1
```

## Value of ${version}

From the oc-describe command above, it uses "v3.7.9" as the value. It could come from:

```sh
# oc version
oc v3.7.9
kubernetes v1.7.6+a08f5eeb62
features: Basic-Auth GSSAPI Kerberos SPNEGO

Server https://ip-172-31-26-164.us-west-2.compute.internal:8443
openshift v3.7.9
kubernetes v1.7.6+a08f5eeb62
```

Even though:

```sh
root@ip-172-31-26-164: ~ # yum list installed | grep openshift
atomic-openshift.x86_64         3.7.9-1.git.0.7c71a2d.el7
...
```

It seems that the "-1" part does not count there.

## Version of components

```sh
# oc get pod -n default -o yaml | grep "image:"
      image: registry.reg-aws.openshift.com:443/openshift3/ose-docker-registry:v3.7.9-1
      image: registry.reg-aws.openshift.com:443/openshift3/registry-console:v3.7
      image: registry.reg-aws.openshift.com:443/openshift3/ose-haproxy-router:v3.7.9-1
```

So registry-console is not controlled by the variable.

The way to control:
* via <code>openshift_cockpit_deployer_version</code> (see [inv examples](https://github.com/openshift/openshift-ansible/blob/master/inventory/byo/hosts.example#L764))

  ```
  oreg_url=registry.reg-aws.openshift.com:443/openshift3/ose-${component}:v3.7.9-1
  openshift_cockpit_deployer_version=v3.7.9-1
  ```

  This leads to (exactly what we want)

  ```sh
  # oc get pod -n default -o yaml | grep "image:"
        image: registry.reg-aws.openshift.com:443/openshift3/ose-docker-registry:v3.7.9-1
        image: registry.reg-aws.openshift.com:443/openshift3/registry-console:v3.7.9-1
        image: registry.reg-aws.openshift.com:443/openshift3/ose-haproxy-router:v3.7.9-1
  ```


* via <code>openshift_pkg_version</code> (see [inv examples](https://github.com/openshift/openshift-ansible/blob/master/inventory/byo/hosts.example#L409))

  ```
  openshift_pkg_version=-3.7.9-1.git.0.7c71a2d.el7
  openshift_cockpit_deployer_version=v3.7.9-1
  ```

  This leads to

  ```sh
  # oc get pod -n default -o yaml | grep "image:"
        image: registry.reg-aws.openshift.com:443/openshift3/ose-docker-registry:v3.7.9
        image: registry.reg-aws.openshift.com:443/openshift3/registry-console:v3.7.9-1
        image: registry.reg-aws.openshift.com:443/openshift3/ose-haproxy-router:v3.7.9
  ```

  Observe that

  * version of docker-reg and router is still v3.7.9. This is because 

    ```
    TASK [openshift_version : Use openshift.common.version fact as version to configure if already installed] ***
    Wednesday 22 November 2017  17:11:30 +0000 (0:00:00.027)       0:01:21.932 **** 
    ok: [ec2-54-149-61-170.us-west-2.compute.amazonaws.com] => {"ansible_facts": {"openshift_version": "3.7.9"}, "changed": false, "failed": false}

    TASK [openshift_version : Set rpm version to configure if openshift_pkg_version specified] ***
    Wednesday 22 November 2017  17:11:30 +0000 (0:00:00.049)       0:01:21.981 **** 
    skipping: [ec2-54-149-61-170.us-west-2.compute.amazonaws.com] => {"changed": false, "skip_reason": "Conditional result was False", "skipped": true}
    ```

    The 2nd task is skipped because openshift_version is defined by the 1st task (see [the task definition](https://github.com/openshift/openshift-ansible/blob/master/roles/openshift_version/tasks/set_version_rpm.yml#L2)).

  * By the time we run this test, tag v3.7.9 has been restored

    ```sh
    $ oc get is -n openshift3 ose-deployer -o yaml | grep "tag:" | cut -f2 -d":" | sort -V | tail -n 2
     v3.7.9
     v3.7.9-1
    ```

    And the all pods are running well:

    ```sh
    # oc get pod -n default
    NAME                       READY     STATUS    RESTARTS   AGE
    docker-registry-1-g8sqx    1/1       Running   0          47m
    registry-console-1-bg4mx   1/1       Running   0          46m
    router-1-95p6n             1/1       Running   0          49m
    ```
