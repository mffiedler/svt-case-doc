# Next-Gen Installer for OCP 4.0

[repo](https://github.com/openshift/installer)

## Doc

* [gdoc@oc-dev](https://docs.google.com/document/d/1j7bhLXT_cIAjpMh_x2jeegtpE7495Mj5A-EcQsgZEDo/edit)
* [libvirt.on.gce@mike](https://github.com/mffiedler/ocp-svt/blob/master/svt-notes/OCP4/openshift4-libvirt-ocp.md)
* ravi: [playbook](https://github.com/chaitanyaenr/ocp-automation/pull/2), [gdoc](https://docs.google.com/document/d/1NilGxOee6DU6_Yim7TgQx6nN51qc2CvFNDqxgv-1NQ4/edit)

## Steps

### AWS

* Get output of `gpg2 --export --armor hongkliu@redhat.com`. See [how2](tools/gpg.md) 

* Fill the form in the above gdoc to get an IAM account on aws.

Then the application got replied, all the credentials for the IAM user are encrypted as a file
in the attachment. Decrypt by:

```bash
$ gpg2 -d ./hongkliu\@redhat.com.openshift-dev.credentials.txt.gpg
```



### libvert

#### libvert on AWS
https://www.reddit.com/r/aws/comments/993zbz/nested_virtualization_within_ec2_need_advice/


### libvert on GCE

Get an GCE instance:

1. Use `redhat` (google-account) to register for a 10 node Tectonic license at [https://account.coreos.com/](https://account.coreos.com/)
2. Download the pull secret and save it as `openshift-pull-secret.json`
3. install gcloud-cli and configure it. See [how2](../cloud/gce/gce.md#google-cloud-cli)

```bash
$ INSTANCE_NAME=hongkliu-ocp40-ttt
$ gcloud compute instances create "${INSTANCE_NAME}" \
    --image-family openshift4-libvirt \
    --zone us-east1-c \
    --min-cpu-platform "Intel Haswell" \
    --machine-type n1-standard-8 \
    --boot-disk-type pd-ssd --boot-disk-size 256GB \
    --metadata-from-file openshift-pull-secret=openshift-pull-secret.json
    

$ gcloud compute --project "openshift-gce-devel" ssh --zone "us-east1-c" "${INSTANCE_NAME}"
### the first time to run the above command, it will generate the key files and save them in ~/.ssh folder
### afterwards, it will use the generated key files to do the ssh

$ ll ~/.ssh/g*
-rw-------. 1 hongkliu hongkliu 1675 Nov  6 16:42 /home/hongkliu/.ssh/google_compute_engine
-rw-r--r--. 1 hongkliu hongkliu  410 Nov  6 16:42 /home/hongkliu/.ssh/google_compute_engine.pub
-rw-r--r--. 1 hongkliu hongkliu  189 Nov  6 16:43 /home/hongkliu/.ssh/google_compute_known_hosts


### we can also use the external IP (got it from the host) and the pub key to ssh the instance
$ ssh -i ~/.ssh/google_compute_engine.pub hongkliu@35.231.72.97


```

Create OCP 4.0 cluster

```bash
$ create-cluster nested
### be patient

$ oc get pod --all-namespaces

```

Lots of puzzles there:
* what is so special of `openshift4-libvirt` images?
* which part enables nested virtualization?
* [packer](https://www.packer.io/) seems a cool tool. Want to learn it.
