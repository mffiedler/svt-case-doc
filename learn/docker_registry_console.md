# Docker Registry Console

## Authentication info
Login with browser the docker registery console, for example https://registry-console-default.apps.0920-iad.qe.rhcloud.com.
The <code>docker-login</code> command shows up on the page:

```
$ sudo docker login -p <secret>--aug -e unused -u unused docker-registry-default.apps.0920-iad.qe.rhcloud.com
```

Note that up to the docker version we may need to remove <code>-e unused</code> part in the above command.

## Login

```sh
$ sudo vi /etc/docker/daemon.json
{
"insecure-registries" : ["docker-registry-default.apps.0920-iad.qe.rhcloud.com"]
}

$ sudo docker pull docker-registry-default.apps.0920-iad.qe.rhcloud.com/hongkliu-docker/hello-world:0.0.1
Trying to pull repository docker-registry-default.apps.0920-iad.qe.rhcloud.com/hongkliu-docker/hello-world ... 
unauthorized: authentication required

$ sudo systemctl restart docker
$ docker pull docker-registry-default.apps.0920-iad.qe.rhcloud.com/hongkliu-docker/hello-world:0.0.1
Trying to pull repository docker-registry-default.apps.0920-iad.qe.rhcloud.com/hongkliu-docker/hello-world ... 
sha256:a5074d61e1e0175fb3a46e0bab46b1f764380ad00cac0e71d53bd4917d196988: Pulling from docker-registry-default.apps.0920-iad.qe.rhcloud.com/hongkliu-docker/hello-world
5b0f327be733: Pull complete 
Digest: sha256:a5074d61e1e0175fb3a46e0bab46b1f764380ad00cac0e71d53bd4917d196988
Status: Downloaded newer image for docker-registry-default.apps.0920-iad.qe.rhcloud.com/hongkliu-docker/hello-world:0.0.1

```

