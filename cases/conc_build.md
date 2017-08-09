
# Concurrent Build Test

## Cluster

[flexy](../learn/flexy.md) with IOPS volumes.

## Test parameters

Check the parameters in the test case and update them in *conc_builds.sh*:

* Number of iterations: <code>-n</code>
* Number of projects: <code>readonly PROJECT_NUM=50</code>
* Number of concurrent builds: <code>build_array=(1 5 10 20 30 40 50)</code>

## Cron job for checking failed builds

```sh
# crontab -e
*/2 * * * * /root/svt/openshift_performance/ose3_perf/scripts/conc_build_step.sh >> /tmp/aaa.txt
```

Wait at most for 2 mins, the log folders in <code>/tmp</code> folder should be created.

## Run the test

```sh
# svt/openshift_performance/ci/scripts
# nohup bash -x ./conc_builds.sh > /tmp/log.aaa.txt &
```

## log collection

They are in <code>/tmp</code> folder.

### Bz (Internal)

#### [bz 1465325](https://bugzilla.redhat.com/show_bug.cgi?id=1465325)

* Env. 3.5 on EC2 with 80G IOPS:

|           | number | type       |
|-----------|--------|------------|
| master    | 1      | m4.2xlarge |
| etcd      | 1      | m4.xlarge  |
| infra     | 1      | m4.2xlarge |
| computing | 15     | m4.xlarge  |


* Use PVC(io1) as [docker-registry](../learn/docker_registry.md) volume.
* Parameters:
  * round1 (warm-up): app=phpcake; project/concurrent_build=60; n/iteration=50;
  * round2 (bug-verification): app=phpcake; project/concurrent_build=300; n/iteration=50 or 100;

[Result](http://file.rdu.redhat.com/~hongkliu/test_result/20170809.conc.build/).
