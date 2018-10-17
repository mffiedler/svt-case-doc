# AWS EFS

* [getting-started](https://docs.aws.amazon.com/efs/latest/ug/getting-started.html)
* [install amazon-efs-utils*rpm](https://docs.aws.amazon.com/efs/latest/ug/using-amazon-efs-utils.html#installing-other-distro)

## Create efs File system

Get the File System ID of the created efs.

### efs console
File System ID: fs-ceb2a867

### [cli](https://docs.aws.amazon.com/cli/latest/reference/efs/create-file-system.html)

```sh
###ref: https://docs.aws.amazon.com/efs/latest/ug/wt1-create-efs-resources.html
(awsenv) [hongkliu@hongkliu awscli]$ aws efs create-file-system --region us-west-2 --creation-token $(cat /proc/sys/kernel/random/uuid)

### describe, add tag, create mount target
$ aws efs describe-file-systems --region us-west-2 --file-system-id fs-2a886d82
$ aws efs create-tags --file-system-id fs-2a886d82 --region us-west-2 --tags Key=Name,Value=hongkliu-test-efs-bbb
$ aws efs create-mount-target --file-system-id fs-2a886d82 --region us-west-2 --subnet-id subnet-4879292d --security-group sg-5c5ace38

```

## Mount efs fs

```sh
###Tested with AMI: ocp-3.11.22-1-SVT-rhel-m5-gold (ami-07a4cf7e0d75f602e)
# git clone https://github.com/aws/efs-utils
# cd efs-utils/
# make rpm
# yum -y install ./build/amazon-efs-utils*rpm
# mkdir /mnt/efs
# mount -t efs fs-2a886d82:/ /mnt/efs
# df -hT | grep efs
fs-ceb2a867.efs.us-west-2.amazonaws.com:/ nfs4      8.0E     0  8.0E   0% /mnt/efs

```

