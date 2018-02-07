# Fading docker

Tested on Fedora 27:

```sh
### Launch an ec2-instance on aws
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-959441ed     --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.large --key-name id_rsa_perf     --subnet subnet-4879292d --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 30}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fedora27-test\"}]}]"
[
    "i-0248dd812b5f66e54"
]
```

Run the following commands on the ec2-instance.

Install `podman`: check [there](https://github.com/projectatomic/libpod/blob/master/docs/tutorials/podman_tutorial.md) for details.

Build from src for the moment. I believe that `dnf` is on its way ([WIP](https://bugzilla.redhat.com/show_bug.cgi?id=1541554)?).

```sh
$ sudo -i
# dnf install -y git runc libassuan-devel golang golang-github-cpuguy83-go-md2man glibc-static \
                                    gpgme-devel glib2-devel device-mapper-devel libseccomp-devel \
                                    atomic-registries iptables skopeo-containers containernetworking-cni \
                                    conmon

# git clone https://github.com/projectatomic/libpod/ ~/src/github.com/projectatomic/libpod
# cd !$
# make
# make install PREFIX=/usr
# podman -v
podman version 0.1

```

Do some container operations as docker does:

```sh
### run tomcat
# podman run -d -p 8080 docker.io/tomcat:8.0

### Such better output than `runc list`
# podman ps
CONTAINER ID   IMAGE                  COMMAND           CREATED AT                      STATUS              PORTS                                                                                            NAMES
41515f4f76e1   docker.io/tomcat:8.0   catalina.sh run   2018-02-07 20:27:14 +0000 UTC   Up 26 seconds ago   0.0.0.0:8080->8080/udp, 0.0.0.0:8080->8080/tcp, 0.0.0.0:8080->8080/udp, 0.0.0.0:8080->8080/tcp   tender_hopper

### Check tomcat service
# curl localhost:8080

### ssh to container, as docker-exec
# podman exec -t 41515f4f76e1 bash
root@41515f4f76e1:/# exit

### Stop container
# podman stop 41515f4f76e1
### Remove container
# podman rm 41515f4f76e1

# podman images
REPOSITORY                 TAG   IMAGE ID       CREATED       SIZE
docker.io/library/tomcat   8.0   7acf2bade9a1   13 days ago   0B

```

Do some image operations as docker does:

```sh
# show image digests
# podman images --digests

# podman build --file=https://raw.githubusercontent.com/hongkailiu/svt-go-docker/podman/Dockerfile
buildah not found in PATH: exec: "buildah": executable file not found in $PATH

# dnf install -y buildah
# curl -o Dockerfile -L  https://raw.githubusercontent.com/hongkailiu/svt-go-docker/podman/Dockerfile

# build image with the dockerfile
# podman build --file=./Dockerfile -t docker.io/<username>/testpodman:latest

# podman images | grep testpodman
docker.io/<username>/testpodman   latest   539197f16127   About a minute ago   12.1MB

# podman login docker.io -u <username>
Password: 
error creating directory "/run/user/0/containers": mkdir /run/user/0/containers: no such file or directory

# mkdir -p /run/user/0/containers
# podman login docker.io -u hongkailiu
Password: 
Login Succeeded!

### not the same syntax as docker push, but close enough
### https://github.com/projectatomic/libpod/blob/master/docs/podman-push.1.md
# podman push 539197f16127 docker://docker.io/hongkailiu/testpodman:latest


```



================================


## Original picture

![](../images/atomic.1.png)

So many features reply on docker and soon enough this became restrictions. As a result, this original picture looks like:

![](../images/atomic.2.png)

People want to see alternatives to docker while docker is still dominating containers world.
Here is a very informative slide from [Dan Walsh's presentation](https://primetime.bluejeans.com/a2m/events/playback/4a13ca22-53df-4fee-a61d-514331093d7b).

![](../images/atomic.3.png)

* image format: open container initiative (OCI)
* push/pull images: skopeo
* storage images locally: containers/storage
* execute images: OCI-runtime specification, eg, runc

## [System containers](system_container.md)

This is another way to run containers without docker. Even k8s is not in the picture. The name, system container, comes from the way (to achieve the goal that we want to make Atomic Host OS smaller) that some of the system services are shipped via container.

To run system containers, we need to have:

* container run-time: runc
* container storage: OSTree
* container image: skopeo

And _systemd_ is used for manager the services provided by system containers.

Keep the goal in mind that is to containerize system services, for example, atomic-openshift-node, atomic-openshift-master-api/controllers, etcd, openvswich. Those services can be also run as docker containers.


## [CRI-O](cri_o.md)

A docker implementation for k8s. Put it in another way, we can run k8s with cri-o without docker.

![](http://cri-o.io/assets/images/architecture.png)



Its components:

* OCI compatible runtime, eg, runc
* container storage, eg, overlay2, devicemapper
* container image, a library supporting _skopeo_
* networking (CNI), eg, openshift-SND (using openvswitch), flannel
* container monitoring (conmon)
* security is provided by several core Linux capabilities

So docker is broken down into many things. Since cri-o is for k8s, some of the projects are actually from k8s, such as CNI and monitoring.
