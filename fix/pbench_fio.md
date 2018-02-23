# pbench-fio: 2.14 vs 3.3

## Our gold AMI
AMI ID: ocp-3.7.9-1-SVT-rhel-gold (ami-ea2efe92)

pbench-agent 0.46-78g30019c5 is no longer available. So we pick up an AMI has it pre-installed.

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-ea2efe92     --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 60, \"VolumeType\": \"gp2\"}}, {\"DeviceName\":\"/dev/sdf\", \"Ebs\":{\"VolumeSize\": 1000, \"VolumeType\": \"gp2\"}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fio-test\"}]}]"

```

Make xfs (others are xfs) and mount to `/var/lib/fio`:

```sh
# mkfs.xfs /dev/xvdf
# mkdir /var/lib/fio
# echo "/dev/xvdf /var/lib/fio xfs defaults 0 0" >> /etc/fstab
# mount -a
# df -hT
Filesystem     Type      Size  Used Avail Use% Mounted on
...
/dev/xvdf     xfs      1000G   33M 1000G   1% /var/lib/fio
```

Check the current pbench-fio version:

```sh
# yum install pbench-fio-2.14
# yum list installed | grep pbench
configtools.noarch              0.3.1-2           @copr-pbench                  
pbench-agent.noarch             0.46-78g30019c5   @ndokos-pbench-interim        
pbench-fio.x86_64               2.14-1            @ndokos-pbench-interim        
pbench-sysstat.x86_64           11.2.0-1          @copr-pbench  

```

Run pbench-fio:

```sh
# cat ./test.sh 
#!/bin/bash

echo "001 $(date)"

pbench-kill-tools
pbench-clear-tools
pbench-clear-results

rm -f /var/lib/fio/*

readonly KEY="_2"

pbench-register-tool-set --label=FIO
pbench-fio --test-types=read,write,rw --clients=localhost --config="SEQ_IO${KEY}" --samples=1 --max-stddev=20 --block-sizes=4 --job-file=/root/sequential_io.job --pre-iteration-script=/root/drop-cache.sh

pbench-copy-results


# cat ./sequential_io.job 
[global]
direct=0
sync=0
fsync_on_close=1
time_based=1
runtime=300
clocksource=clock_gettime
ramp_time=300
startdelay=5
directory=/var/lib/fio
filename_format=test.$jobname.$jobnum.$filenum
size=5g
write_bw_log=fio
write_iops_log=fio
write_lat_log=fio
write_hist_log=fio
per_job_logs=1
log_avg_msec=1000
log_hist_msec=1000

[fio-1]
bs=4k
rw=read
nrfiles=16
numjobs=1


# cat ./drop-cache.sh 
#!/bin/bash

sync ; echo 3 > /proc/sys/vm/drop_caches

# chmod +x ./drop-cache.sh 
```


```sh
# bash -x ./test.sh
```

Update pbench-agent/fio version (also change the pbench-config file): I have a playbook to do this.

```sh
# yum list installed | grep pbench
configtools.noarch              0.3.1-2           @copr-pbench                  
pbench-agent.noarch             0.48-171g25cf855  @ndokos-pbench-interim        
pbench-fio.x86_64               3.3-1             @copr-pbench                  
pbench-sysstat.x86_64           11.2.0-1          @copr-pbench     
```

Change pbench data label:

```sh
# vi ./test.sh 
#!/bin/bash
...
readonly KEY="_3"
```


Pbench result: [here](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-63-86/).


### Fedora 27 AMI

Fedora-Cloud-Base-27-1.6.x86_64-us-west-2-HVM-gp2-0 (ami-959441ed): Clean fedora

https://copr.fedorainfracloud.org/coprs/ndokos/pbench/

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-959441ed     --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 60, \"VolumeType\": \"gp2\"}}, {\"DeviceName\":\"/dev/sdf\", \"Ebs\":{\"VolumeSize\": 1000, \"VolumeType\": \"gp2\"}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fio-test\"}]}]"

```

```sh
# wget https://copr.fedorainfracloud.org/coprs/ndokos/pbench/repo/fedora-27/ndokos-pbench-fedora-27.repo
# mv ndokos-pbench-fedora-27.repo /etc/yum.repos.d/

### Add another ndokos repo: pbench-fio is only available there.
# vi /etc/yum.repos.d/ndokos-pbench-interim.repo
[ndokos-pbench-interim]
name=Copr repo for pbench-interim owned by ndokos
baseurl=https://copr-be.cloud.fedoraproject.org/results/ndokos/pbench-interim/epel-7-$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/ndokos/pbench-interim/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1

# dnf  --showduplicates list pbench-fio
Copr repo for pbench-interim owned by ndokos                                                  103 kB/s |  22 kB     00:00    
Last metadata expiration check: 0:00:00 ago on Fri 23 Feb 2018 03:36:34 PM UTC.
Available Packages
pbench-fio.src                                            2.14-1                                         ndokos-pbench-interim
pbench-fio.x86_64                                         2.14-1                                         ndokos-pbench-interim
pbench-fio.src                                            3.3-1                                          ndokos-pbench        
pbench-fio.src                                            3.3-1                                          ndokos-pbench        
pbench-fio.x86_64                                         3.3-1                                          ndokos-pbench        
pbench-fio.x86_64                                         3.3-1                                          ndokos-pbench  
```

```sh
# dnf install pbench-agent pbench-fio-2.14 pbench-sysstat
# dnf list installed | grep pbench
configtools.noarch                  0.3.1-3                    @ndokos-pbench   
pbench-agent.noarch                 0.48-178g25cf855           @ndokos-pbench-interim
pbench-fio.x86_64                   2.14-1                     @ndokos-pbench-interim
pbench-sysstat.x86_64               11.2.0-1                   @ndokos-pbench
```

```sh
### copy /opt/pbench-agent/config/pbench-agent.cfg
### Note change this line: do not know why it does not work with the first line.
#webserver = %(pbench_web_server)s
webserver = perf-infra.ec2.breakage.org

### and /opt/pbench-agent/id_rsa, then
# chmod 0600 /opt/pbench-agent/id_rsa

# vi ~/.bash_profile
...
PATH=/opt/pbench-agent/util-scripts:/opt/pbench-agent/bench-scripts:${PATH}
...

# source ~/.bash_profile

### ssh root@localhost passwordless authentication
# ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# cat ~/.ssh/id_rsa.pub | >> ~/.ssh/authorized_keys
```

```sh
### Use ext4 in fedora
# mkfs.ext4 /dev/xvdf
# mkdir /var/lib/fio
# echo "/dev/xvdf /var/lib/fio ext4 defaults 0 0" >> /etc/fstab
# mount -a
# df -hT
Filesystem     Type      Size  Used Avail Use% Mounted on
...
/dev/xvdf     xfs      1000G   33M 1000G   1% /var/lib/fio
```
