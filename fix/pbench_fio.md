# pbench-fio: 2.14 vs 3.3

AMI ID: ocp-3.9.0-0.46.0-SVT-rhel-gold (ami-a1d75bd9)

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-a1d75bd9     --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 60}}, {\"DeviceName\":\"/dev/sdf\", \"Ebs\":{\"VolumeSize\": 1000}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fio-test\"}]}]"

```

Make xfs (others are xfs) and mount to `/var/lib/fio`:

```sh
# fdisk /dev/xvdf
# partprobe
# cat /proc/partitions
# mkfs.xfs /dev/xvdf1
# mkdir /var/lib/fio
# echo "/dev/xvdf1 /var/lib/fio xfs defaults 0 0" >> /etc/fstab
# df -hT
Filesystem     Type      Size  Used Avail Use% Mounted on
...
/dev/xvdf1     xfs      1000G   33M 1000G   1% /var/lib/fio
```

Check the current pbench-fio version:

```sh
# yum install pbench-fio
# yum list installed | grep pbench
configtools.noarch              0.3.1-3           @copr-pbench                  
pbench-agent.noarch             0.48-178g25cf855  @ndokos-pbench-interim        
pbench-fio.x86_64               3.3-1             @copr-pbench                  
pbench-sysstat.x86_64           11.2.0-1          @copr-pbench

```
