# [glide](https://glide.sh/)

## [Installation](https://glide.readthedocs.io/en/latest/)

Download from [release page](https://glide.readthedocs.io/en/latest/) and put the command line binary <code>glide</code> into <code>${PATH}</code>.

```sh
$ glide --version
glide version v0.13.1
```

## Generate glide.yaml file

```sh
[hongkliu@hongkliu test-go]$ glide init

```

As an example, we will use [k8s client-go](https://github.com/kubernetes/client-go) API as a dependency. [Here](https://github.com/kubernetes/client-go/blob/master/INSTALL.md#glide) is how2.

Example code: [here](https://github.com/hongkailiu/test-go/tree/master/k8s).


## Update dependency
Use code in the new API and add the dependency into <code>glide.yaml</code> file

```sh
$ glide up -v
### IntelliJ will reindex the code from updated dependency list.
```

## [glide vendor cleaner](https://github.com/sgotti/glide-vc)
TODO
