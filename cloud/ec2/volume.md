
## Volumes on EC2

* [General infomation](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Storage.html)
* [Types](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html)
* Follow the doc and find how to create a volume and then attach it to an instance.
* When we launch an instance based on an AMI, there is an option during the wizard to choose the storage.

## Flexy (Internal)

* By default, Flexy will attach GP2 volumes to the created instances.
* See [CUCUSHIFT Param for iops Section](https://docs.google.com/document/d/1TAZf_fu9ckNuVVbXBmzomVXmySmu0SAppHM-92uQeOM/edit#heading=h.8qr7g7g91wg9)
in [1] if IOPS is reuqired.

## Check what type of volumes is attached

* EC2 Consolue: Volumes, Filter by Instance ID.
* CLI: TODO

## Stats

* EC2 Console
* Bash (IOPS)

```sh
# # iostat -p /dev/xvdb 1
Linux 3.10.0-691.el7.x86_64 (ip-172-31-61-63.us-west-2.compute.internal) 	07/07/2017 	_x86_64_	(4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           2.44    0.00    1.20    0.56    0.08   95.72

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
xvdb            134.43      3463.83      2186.52  137494921   86792676

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          24.47    0.00   18.95    6.05    1.05   49.47

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
xvdb           2812.00     37940.00     19477.00      37940      19477

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          11.70    0.00   17.29    9.31    0.53   61.17

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
xvdb           3165.00     76858.00     86449.00      76858      86449

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          29.43    0.00   26.56    7.81    0.78   35.42

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
xvdb           2738.00     48497.50     36813.50      48497      36813

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          31.15    0.00   25.13    9.16    0.79   33.77

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
xvdb           2890.00     55595.00     56796.50      55595      56796
```
where _tps_ is the major parameter.

* pbench



## Reference

[1]. SVT Useful Step
