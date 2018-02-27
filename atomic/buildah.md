# buildah

## Doc

* buildah@atomic: [link1](https://www.projectatomic.io/blog/2017/06/introducing-buildah/), [link2](https://www.projectatomic.io/blog/2017/11/getting-started-with-buildah/)
* [buildah@github](https://github.com/projectatomic/buildah)

## Installation
Tested on Fedora 27:

```sh
$ sudo dnf -y install buildah
$ buildah --version
buildah version 0.12 (image-spec 1.0.0, runtime-spec 1.0.0)
```

## Build an images

Note that `buildah` accepts Dockerfile as input for building images. Here we practice `buildah`'s syntax.

Task: do the same thing as [this Dockerfile](https://github.com/hongkailiu/svt-go-docker/blob/podman/Dockerfile):

```
FROM centos:7
ENV svt_go_version 0.0.1
ENV build_number travis_57
RUN mkdir /myapp
WORKDIR /myapp
RUN curl -o svt-${svt_go_version}-Linux-x86_64.tar.gz "https://raw.githubusercontent.com/cduser/svt-release/${build_number}/svt-${svt_go_version}-Linux-x86_64.tar.gz" && tar -xzf "svt-${svt_go_version}-Linux-x86_64.tar.gz"
CMD ["/myapp/svt/svt", "http"]
```

`buildah` build an image based on a sequence of `buildah` commands. So `Dockerfile` becomes a `shell` script. Let us translate the above Dockerfile:

```
container=$(buildah from centos:7)
buildah config --env "svt_go_version=0.0.1" ${container}
buildah config --env "build_number=travis_57" ${container}
buildah run ${container} -- mkdir /myapp
buildah config ${container} --workingdir /myapp
buildah run ${container} -- curl -o svt-${svt_go_version}-Linux-x86_64.tar.gz "https://raw.githubusercontent.com/cduser/svt-release/${build_number}/svt-${svt_go_version}-Linux-x86_64.tar.gz" && tar -xzf "svt-${svt_go_version}-Linux-x86_64.tar.gz"
buildah config ${container} --cmd "/myapp/svt/svt http"
```
