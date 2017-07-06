
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
* Bash

```sh
# iostat -p /dev/xvdb 10
Linux 3.10.0-691.el7.x86_64 (ip-172-31-31-187.us-west-2.compute.internal) 	07/06/2017 	_x86_64_	(4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           2.95    0.00    0.70    0.16    0.13   96.06

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
xvdb              0.24         3.14         2.95     339066     318094
```
where _tps_ is the major parameter.

* pbench



## Reference

[1]. SVT Useful Step
