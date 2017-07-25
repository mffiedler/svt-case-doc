# Networking

## Doc

* [networking](https://docs.openshift.org/latest/architecture/core_concepts/routes.html)
* [routes](https://docs.openshift.org/latest/architecture/core_concepts/routes.html)
* [service](https://docs.openshift.org/latest/architecture/core_concepts/pods_and_services.html#services)
* [networking@k8s](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

## Flexy

When flexy generates the inventory file (2), the following parameter shows which network plugin is installed:

<code>os_sdn_network_plugin_name=redhat/openshift-ovs-subnet</code>

## Network interfaces on AWS EC2 instances

### master

```sh
# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP qlen 1000
    link/ether 02:ca:ea:35:d0:e4 brd ff:ff:ff:ff:ff:ff
    inet 172.31.62.245/18 brd 172.31.63.255 scope global dynamic eth0
       valid_lft 2551sec preferred_lft 2551sec
    inet6 fe80::ca:eaff:fe35:d0e4/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN 
    link/ether 02:42:59:53:9d:59 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 scope global docker0
       valid_lft forever preferred_lft forever
4: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether ee:19:bb:77:62:a4 brd ff:ff:ff:ff:ff:ff
5: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 36:be:b4:b5:da:48 brd ff:ff:ff:ff:ff:ff
9: vxlan_sys_4789: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65470 qdisc noqueue master ovs-system state UNKNOWN qlen 1000
    link/ether ba:02:ac:9a:97:6b brd ff:ff:ff:ff:ff:ff
    inet6 fe80::b802:acff:fe9a:976b/64 scope link 
       valid_lft forever preferred_lft forever
10: tun0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN qlen 1000
    link/ether 96:68:8b:bd:e3:5c brd ff:ff:ff:ff:ff:ff
    inet 172.20.0.1/24 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::9468:8bff:febd:e35c/64 scope link 
       valid_lft forever preferred_lft forever
```

### other nodes

More network interfaces like the following:

```sh
13: veth58d5e401@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue master ovs-system state UP 
    link/ether 16:45:f0:1b:b2:c0 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::1445:f0ff:fe1b:b2c0/64 scope link 
       valid_lft forever preferred_lft forever
```

## Reference

* [SRV record](https://en.wikipedia.org/wiki/SRV_record)
* [SkyDNS](https://github.com/skynetservices/skydns)
* [Dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)
