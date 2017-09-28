# OpenShift Online

Each of the following environment has integration, staging, and production cluster.

* [openshift.com](https://www.openshift.com/): clusters are usually deployed in different
regions in AWS.

    * online starter: free for developers with limited resources.
    * online pro: [pricing](https://www.openshift.com/pricing/index.html)
    * online dedicated: enterprise usage which could be deployed in Azure or GCE as well.

    From SVT respective, focus for now is starter and pro, mostly with integration and staging cluster.


* [openshift.io](https://openshift.io/): free for developers with limited resources,
similar to online starter.

    *It seems that .io links to starter of .com*


## pro [online-int](https://api.online-int.openshift.com) (internal)
One registered RH account should have access to all online cluster.

### UI access (deprecated on Sep 28, 2017: No need with proxy)

vpn + proxy:

```sh
$ google-chrome --proxy-server="http://file.rdu.redhat.com:3128" > /dev/null 2>&1 &
```

### OC client access
vpn + libra.perm to Vikas' magic VM (deprecated on Sep 28, 2017).

Sep 28, 2017:
See [internal mojo page](https://mojo.redhat.com/docs/DOC-1144200#jive_content_id_Tier_1).
