# Container

* [what-even-is-a-container](https://jvns.ca/blog/2016/10/10/what-even-is-a-container/)
* [Cgroups, namespaces, and beyond: what are containers made from?](https://www.youtube.com/watch?v=sK5i-N34im8)

## namespace

[linux-namespaces](https://medium.com/@teddyking/linux-namespaces-850489d3ccf)
[namespace overview](https://lwn.net/Articles/531114/)
[chroot-cgroups-and-namespaces](https://itnext.io/chroot-cgroups-and-namespaces-an-overview-37124d995e3d)

```bash
### https://prefetch.net/blog/2018/02/22/making-sense-of-linux-namespaces/
# oc new-project test-project
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/template_test.yaml | oc create -f -
# oc get pod -o wide
NAME          READY     STATUS    RESTARTS   AGE       IP            NODE                                          NOMINATED NODE
web-1-j7s2c   1/1       Running   0          17m       172.20.0.24   ip-172-31-47-223.us-west-2.compute.internal   <none>
# ps aux 
USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
1000270+      1  0.0  0.0 113468  3572 ?        Ssl  16:43   0:00 ./svt/svt http
1000270+     17  0.0  0.0  11760  1688 ?        Ss   17:00   0:00 /bin/sh
1000270+     23  0.0  0.0  47436  1676 ?        R+   17:00   0:00 ps aux

# ssh ip-172-31-47-223.us-west-2.compute.internal
# lsns -p 40211
        NS TYPE  NPROCS   PID USER       COMMAND
4026531837 user     268     1 root       /usr/lib/systemd/systemd --switched-root --system --deserialize 21
4026533473 ipc        2 39945 pbench     /usr/bin/pod
4026533476 net        2 39945 pbench     /usr/bin/pod
4026533535 mnt        1 40211 1000270000 ./svt/svt http
4026533536 uts        1 40211 1000270000 ./svt/svt http
4026533537 pid        1 40211 1000270000 ./svt/svt http


# docker ps -a | grep -E "test-project"
b3c59c2002e4        docker.io/hongkailiu/svt-go@sha256:6b9d8e51c68409d58e925ef4a04b3bb5411a9cd63e360627a7a43ad82c87d691                                                     "./svt/svt http"         31 minutes ago      Up 31 minutes                                k8s_web_web-1-j7s2c_test-project_09875525-c599-11e8-83cf-0247965dac80_0
83f01546e721        registry.reg-aws.openshift.com:443/openshift3/ose-pod:v3.11.16                                                                                          "/usr/bin/pod"           31 minutes ago      Up 31 minutes                                k8s_POD_web-1-j7s2c_test-project_09875525-c599-11e8-83cf-0247965dac80_0

# docker ps -a | awk '/test-project/ { print $1}'
b3c59c2002e4
83f01546e721
root@ip-172-31-47-223: ~ # docker inspect $(docker ps -a | awk '/test-project/ { print $1}') -f '{{ .State.Pid }}'
40211
39945

# curl -LO https://raw.githubusercontent.com/Matty9191/container-research/master/scripts/sharedns.py
# python ./sharedns.py | egrep '40211|39945|Name'
Namespace ID          Namespace   Pids Sharing Namespace
4026531837            user        1,2,3,5,7,8,9,10,11,12,13,14,16,17,18,19,21,22,23,24,26,28,29,30,31,32,33,34,35,36,37,38,39,46,47,48,49,57,59,60,63,65,78,182,308,619,620,621,639,1358,1362,1366,1373,1374,1375,1376,1378,1379,1380,1382,1383,1477,1496,1499,2286,2288,2289,2290,2291,2294,2299,2310,2702,2729,2730,2749,2774,2782,2806,2812,2843,3485,3490,3565,3638,3649,3699,3722,6688,6707,6767,6790,6842,8480,8496,8528,8545,8585,8602,8645,8662,8747,8748,8813,8814,11279,12387,15577,15594,16120,16127,16234,16261,17347,17366,17427,18741,18766,18808,18827,19969,19987,20086,20106,20418,20436,20524,20543,20578,20774,20791,21241,21289,21503,21526,22502,22558,22576,22694,22711,22860,22876,22940,22957,23252,23272,24542,24561,24675,24758,24759,24762,24779,24848,24867,24895,24912,24959,24975,24987,24988,24999,25122,25139,25169,25186,25305,25324,25740,25757,25951,25975,26035,26051,26208,26230,26240,26241,26320,26344,27366,27384,27941,27958,28002,28021,28193,28209,28665,28684,29066,29083,29241,29258,29329,29351,29626,29644,29907,29930,30278,30296,30334,30351,30530,30548,30621,30641,30713,30732,30885,30904,30993,31010,31188,31205,32491,32508,32844,32863,33067,33093,33225,33246,34248,34268,34916,34936,35496,35523,35726,35743,36001,36019,36615,39926,39945,40194,40211,40260,40261,40332,42282,42283,42284,42324,42336,42337,42422,42435,42447,42464,42503,42520,48251,48286,52399,53408,89081,89711,93677,96579,100512,100801,101388,102758,102838,102863,102864
4026533473            ipc         39945,40211         
4026533474            pid         39945               
4026533535            mnt         40211               
4026533476            net         39945,40211         
4026533472            uts         39945               
4026533537            pid         40211               
4026533471            mnt         39945               
4026533536            uts         40211           

```

## cgroup

* [very nice toturial on cgroup](https://sysadmincasts.com/episodes/14-introduction-to-linux-control-groups-cgroups)
* linux kernel doc on cgroup: [v1](https://www.kernel.org/doc/Documentation/cgroup-v1/), [v2](https://www.kernel.org/doc/Documentation/cgroup-v2.txt)
* [red hat doc on cgroup](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html-single/resource_management_guide/index#idm53784800)