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

$ sudo systemctl restart docker
$ docker pull docker-registry-default.apps.0920-iad.qe.rhcloud.com/hongkliu-docker/hello-world:0.0.1
```

