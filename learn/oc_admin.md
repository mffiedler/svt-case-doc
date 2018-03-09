# Openshift Administration

## Image access
Create a project `rhgs3` on [reg-aws.openshift.com](https://console.reg-aws.openshift.com/console/).
We show that how to push/pull images to/from that project.

### Push

Create the jump note:

```sh
(osenv) [hongkliu@hongkliu oscli]$ openstack --os-cloud os10 server create --availability-zone nova --image rhel-atomic-cloud-7.3.4-8 --flavor m1.medium --network openshift-qe-jenkins --security-group default --key-name libra --min 1 --max 1 qe-hongkliu-test-0309-jp
```

See [cns_internal.md](../storage/cns_internal.md) for setting up docker and checking the images tags in brew.

```sh
### docker login for pushing images to registry.reg-aws.openshift.com
# docker login -u <kerberos>@redhat.com -p $(oc whoami -t) registry.reg-aws.openshift.com:443
```

```sh
# docker pull brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-s3-server-rhel7:3.3.1-4
# docker tag brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-s3-server-rhel7:3.3.1-4 registry.reg-aws.openshift.com:443/rhgs3/rhgs-s3-server-rhel7:3.3.1-4
# docker push registry.reg-aws.openshift.com:443/rhgs3/rhgs-s3-server-rhel7:3.3.1-4
# docker pull brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7:3.3.1-7
# docker tag brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7:3.3.1-7 registry.reg-aws.openshift.com:443/rhgs3/rhgs-server-rhel7:3.3.1-7
# docker push registry.reg-aws.openshift.com:443/rhgs3/rhgs-server-rhel7:3.3.1-7
# docker pull brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-volmanager-rhel7:3.3.1-4
# docker tag brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-volmanager-rhel7:3.3.1-4 registry.reg-aws.openshift.com:443/rhgs3/rhgs-volmanager-rhel7:3.3.1-4
# docker push registry.reg-aws.openshift.com:443/rhgs3/rhgs-volmanager-rhel7:3.3.1-4
# docker pull brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-gluster-block-prov-rhel7:3.3.1-3
# docker tag brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-gluster-block-prov-rhel7:3.3.1-3 registry.reg-aws.openshift.com:443/rhgs3/rhgs-gluster-block-prov-rhel7:3.3.1-3
# docker push registry.reg-aws.openshift.com:443/rhgs3/rhgs-gluster-block-prov-rhel7:3.3.1-3

```

* Allow other users to push images: NOT tested yet

```sh
### Allow other user to push iamges
# oc project rhgs3
# oc adm policy add-role-to-group system:image-pusher system:authenticated
### Add antoher user as admin and admin can push too
# oc adm policy add-role-to-user admin <another_admin>@redhat.com -n rhgs3
```

## Pull

```sh
# docker pull registry.reg-aws.openshift.com:443/rhgs3/rhgs-gluster-block-prov-rhel7:3.3.1-3
```

* Allow other users to pull images

```sh
### Allow all authenticated users to pull iamges
# oc project rhgs3
# oc adm policy add-role-to-group system:image-puller system:authenticated
``
