# Prepare for online test: conc-build (Internal)


## Launch a plain t2.medium AWS instance from EC2 web console

Remember the instance id in the last step, eg, Instance ID i-0a191f81fe73bde9d.
Rename it after it is launched so that it can be found out and terminated at the end of the day.

| Tables        | Are           |
|-------------:|:-------------|
|Instance ID|i-0a191f81fe73bde9d|
|Instance type|~~t2.medium~~ t2.2xlarge(500 concurrent builds)|
|AMI ID|RHEL-7.3_HVM-20170613-x86_64-4-Hourly2-GP2 (ami-b55a51cc)|


## Install atomic-openshift-clients 3.5.x

Upload repo certificate files:

```sh
$ scp -i ~/.ssh/id_rsa_perf client*.pem ec2-user@ec2-<secret>.compute.amazonaws.com:~/
```

Ssh to the test host:

```sh
$ ssh -i ~/.ssh/id_rsa_perf ec2-user@ec2-<secret>.compute.amazonaws.com
$ sudo mv client*.pem /var/lib/yum/
$ sudo -i
```


Create yum repo:

```sh
# vi /etc/yum.repos.d/aos.repo
# cat /etc/yum.repos.d/aos.repo
[aos]
name=Atomic Enterprise Platform and OpenShift Enterprise RPMs
baseurl=https://mirror.openshift.com/enterprise/enterprise-3.5/latest/RH7-RHAOS-3.5/x86_64/os
failovermethod=priority
enabled=1
gpgcheck=0
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem

# yum install atomic-openshift-clients
# oc version
oc v3.5.5.31
kubernetes v1.5.2+43a9be4
features: Basic-Auth GSSAPI Kerberos SPNEGO
```

Install dependencies used for cluster-loader.py to create projects

```sh
# curl -o ./get-pip.py https://bootstrap.pypa.io/get-pip.py
# python ./get-pip.py
# pip install boto3
# pip install python-cephlibs
# pip install flask
```

Skip this step when using online

```sh
# oc login https://ec2-<secret>.compute.amazonaws.com:8443 --token=<secret>
```

Needed only when using online (add online entry)
```sh
# vi /etc/hosts
```

Test authentication

```sh
# oc get nodes
```

Prepare svt repo

```sh
# git clone https://github.com/hongkailiu/svt.git
# cd svt
# git checkout online3.5
# git log -n 1
```

Run conc_builds.sh

```sh
# cd openshift_performance/ci/scripts/
# ./conc_builds.sh
```

Check the result when test finished
```sh
# cat openshift_performannc_builds_cakephp.out
```

Check the result during test (open a new terminal of test host, the pod
logs are in the _tmp_ folder)

```sh
# /root/svt/manual.steps/conc_build_step.sh
# /tmp/<ddmmyyyy>_conc_builds
```

Check the result when test finished

```sh
# cat conc_builds_cakephp.out
```

Upload the result file
```sh
# scp conc_builds_*.out <some_server>
```

Move to the next app: ("cakephp" "eap" "django" "nodejs")

```sh
# vi conc_builds.sh
app_array=("django")
```

Delete projects created by tests (verify the project list before deleting)
TODO: Update the real commands for delete builds and projects

```sh
# oc get projects -l purpose=test
# oc delete project -l purpose=test

TODO
Update how to do 500 concurrent and -n=10 instead of 50
```
