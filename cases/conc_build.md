
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

## Run the test

```sh
# svt/openshift_performance/ci/scripts
# nohup bash -x ./conc_builds.sh > /tmp/log.aaa.txt &
```

## log collection

They are in <code>/tmp</code> folder.
