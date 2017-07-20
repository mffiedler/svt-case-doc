# EC2

## Install [aws cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)

```sh
$ pwd
/home/hongkliu/tool/awscli
$ virtualenv awsenv
$ source awsenv/bin/activate
(awsenv) [hongkliu@hongkliu awscli]$ pip install  awscli
(awsenv) [hongkliu@hongkliu awscli]$ aws --version
aws-cli/1.11.121 Python/2.7.5 Linux/3.10.0-514.21.1.el7.x86_64 botocore/1.5.84
(awsenv) [hongkliu@hongkliu awscli]$ aws help
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 help

```


## [Configure](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws configure
AWS Access Key ID [None]: <ask_flexy_output>
AWS Secret Access Key [None]: <ask_flexy_output>
Default region name [None]: us-west-2
Default output format [None]: json
(awsenv) [hongkliu@hongkliu awscli]$ ls ~/.aws/
config  credentials
```

## [Cli tutorial](http://docs.aws.amazon.com/cli/latest/userguide/tutorial-ec2-ubuntu.html)

### Useful commands

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-f2d3cd8b --security-group-ids sg-5c5ace38 --count 2 --instance-type m4.xlarge --key-name id_rsa_perf --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 60}}]" --query 'Instances[*].InstanceId'
[
    "i-09b960edd26316b8e", 
    "i-0d11e05b64fcf6ca1"
]

(awsenv) [hongkliu@hongkliu awscli]$ aws ec2  create-tags --resources i-0f6469875f9e471d3 --tags "Key=Name,Value=qe-hongkliu-ttt"
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 describe-instances --filters 'Name=tag:Name,Values=*hongkliu*'
{
    "Reservations": [
        {
            "Instances": [
                {
                    "Monitoring": {
                        "State": "disabled"
                    }, 
                    "PublicDnsName": "ec2-54-186-191-136.us-west-2.compute.amazonaws.com", 
                    "State": {
                        "Code": 16, 
                        "Name": "running"
                    }, 
                    "EbsOptimized": false, 
                    "LaunchTime": "2017-07-20T00:08:10.000Z", 
                    "PublicIpAddress": "54.186.191.136", 
                    "PrivateIpAddress": "172.31.47.73", 
                    "ProductCodes": [], 
                    "VpcId": "vpc-33b5f656", 
                    "StateTransitionReason": "", 
                    "InstanceId": "i-0f6469875f9e471d3", 
                    "ImageId": "ami-f2d3cd8b", 
                    "PrivateDnsName": "ip-172-31-47-73.us-west-2.compute.internal", 
                    "KeyName": "id_rsa_perf", 
                    "SecurityGroups": [
                        {
                            "GroupName": "default", 
                            "GroupId": "sg-5c5ace38"
                        }
                    ], 
                    "ClientToken": "", 
                    "SubnetId": "subnet-4879292d", 
                    "InstanceType": "m4.xlarge", 
                    "NetworkInterfaces": [
                        {
                            "Status": "in-use", 
                            "MacAddress": "02:48:81:e9:d7:22", 
                            "SourceDestCheck": true, 
                            "VpcId": "vpc-33b5f656", 
                            "Description": "", 
                            "NetworkInterfaceId": "eni-cf8e51e3", 
                            "PrivateIpAddresses": [
                                {
                                    "PrivateDnsName": "ip-172-31-47-73.us-west-2.compute.internal", 
                                    "PrivateIpAddress": "172.31.47.73", 
                                    "Primary": true, 
                                    "Association": {
                                        "PublicIp": "54.186.191.136", 
                                        "PublicDnsName": "ec2-54-186-191-136.us-west-2.compute.amazonaws.com", 
                                        "IpOwnerId": "amazon"
                                    }
                                }
                            ], 
                            "PrivateDnsName": "ip-172-31-47-73.us-west-2.compute.internal", 
                            "Attachment": {
                                "Status": "attached", 
                                "DeviceIndex": 0, 
                                "DeleteOnTermination": true, 
                                "AttachmentId": "eni-attach-c8867a23", 
                                "AttachTime": "2017-07-20T00:08:10.000Z"
                            }, 
                            "Groups": [
                                {
                                    "GroupName": "default", 
                                    "GroupId": "sg-5c5ace38"
                                }
                            ], 
                            "Ipv6Addresses": [], 
                            "OwnerId": "925374498059", 
                            "PrivateIpAddress": "172.31.47.73", 
                            "SubnetId": "subnet-4879292d", 
                            "Association": {
                                "PublicIp": "54.186.191.136", 
                                "PublicDnsName": "ec2-54-186-191-136.us-west-2.compute.amazonaws.com", 
                                "IpOwnerId": "amazon"
                            }
                        }
                    ], 
                    "SourceDestCheck": true, 
                    "Placement": {
                        "Tenancy": "default", 
                        "GroupName": "", 
                        "AvailabilityZone": "us-west-2b"
                    }, 
                    "Hypervisor": "xen", 
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/sda1", 
                            "Ebs": {
                                "Status": "attached", 
                                "DeleteOnTermination": true, 
                                "VolumeId": "vol-07085079b8d19fb0f", 
                                "AttachTime": "2017-07-20T00:08:11.000Z"
                            }
                        }, 
                        {
                            "DeviceName": "/dev/sdb", 
                            "Ebs": {
                                "Status": "attached", 
                                "DeleteOnTermination": true, 
                                "VolumeId": "vol-0370c480b795a127d", 
                                "AttachTime": "2017-07-20T00:08:11.000Z"
                            }
                        }
                    ], 
                    "Architecture": "x86_64", 
                    "RootDeviceType": "ebs", 
                    "RootDeviceName": "/dev/sda1", 
                    "VirtualizationType": "hvm", 
                    "Tags": [
                        {
                            "Value": "qe-hongkliu-ttt", 
                            "Key": "Name"
                        }
                    ], 
                    "AmiLaunchIndex": 1
                }, 
                {
                    "Monitoring": {
                        "State": "disabled"
                    }, 
                    "PublicDnsName": "ec2-54-200-204-22.us-west-2.compute.amazonaws.com", 
                    "State": {
                        "Code": 16, 
                        "Name": "running"
                    }, 
                    "EbsOptimized": false, 
                    "LaunchTime": "2017-07-20T00:08:10.000Z", 
                    "PublicIpAddress": "54.200.204.22", 
                    "PrivateIpAddress": "172.31.18.182", 
                    "ProductCodes": [], 
                    "VpcId": "vpc-33b5f656", 
                    "StateTransitionReason": "", 
                    "InstanceId": "i-048c94c680090ce7d", 
                    "ImageId": "ami-f2d3cd8b", 
                    "PrivateDnsName": "ip-172-31-18-182.us-west-2.compute.internal", 
                    "KeyName": "id_rsa_perf", 
                    "SecurityGroups": [
                        {
                            "GroupName": "default", 
                            "GroupId": "sg-5c5ace38"
                        }
                    ], 
                    "ClientToken": "", 
                    "SubnetId": "subnet-4879292d", 
                    "InstanceType": "m4.xlarge", 
                    "NetworkInterfaces": [
                        {
                            "Status": "in-use", 
                            "MacAddress": "02:c3:5e:63:81:14", 
                            "SourceDestCheck": true, 
                            "VpcId": "vpc-33b5f656", 
                            "Description": "", 
                            "NetworkInterfaceId": "eni-3d944b11", 
                            "PrivateIpAddresses": [
                                {
                                    "PrivateDnsName": "ip-172-31-18-182.us-west-2.compute.internal", 
                                    "PrivateIpAddress": "172.31.18.182", 
                                    "Primary": true, 
                                    "Association": {
                                        "PublicIp": "54.200.204.22", 
                                        "PublicDnsName": "ec2-54-200-204-22.us-west-2.compute.amazonaws.com", 
                                        "IpOwnerId": "amazon"
                                    }
                                }
                            ], 
                            "PrivateDnsName": "ip-172-31-18-182.us-west-2.compute.internal", 
                            "Attachment": {
                                "Status": "attached", 
                                "DeviceIndex": 0, 
                                "DeleteOnTermination": true, 
                                "AttachmentId": "eni-attach-cb867a20", 
                                "AttachTime": "2017-07-20T00:08:10.000Z"
                            }, 
                            "Groups": [
                                {
                                    "GroupName": "default", 
                                    "GroupId": "sg-5c5ace38"
                                }
                            ], 
                            "Ipv6Addresses": [], 
                            "OwnerId": "925374498059", 
                            "PrivateIpAddress": "172.31.18.182", 
                            "SubnetId": "subnet-4879292d", 
                            "Association": {
                                "PublicIp": "54.200.204.22", 
                                "PublicDnsName": "ec2-54-200-204-22.us-west-2.compute.amazonaws.com", 
                                "IpOwnerId": "amazon"
                            }
                        }
                    ], 
                    "SourceDestCheck": true, 
                    "Placement": {
                        "Tenancy": "default", 
                        "GroupName": "", 
                        "AvailabilityZone": "us-west-2b"
                    }, 
                    "Hypervisor": "xen", 
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/sda1", 
                            "Ebs": {
                                "Status": "attached", 
                                "DeleteOnTermination": true, 
                                "VolumeId": "vol-0bea709c89ec63d73", 
                                "AttachTime": "2017-07-20T00:08:11.000Z"
                            }
                        }, 
                        {
                            "DeviceName": "/dev/sdb", 
                            "Ebs": {
                                "Status": "attached", 
                                "DeleteOnTermination": true, 
                                "VolumeId": "vol-07d33cb43b822c2b5", 
                                "AttachTime": "2017-07-20T00:08:11.000Z"
                            }
                        }
                    ], 
                    "Architecture": "x86_64", 
                    "RootDeviceType": "ebs", 
                    "RootDeviceName": "/dev/sda1", 
                    "VirtualizationType": "hvm", 
                    "Tags": [
                        {
                            "Value": "qe-hongkliu-ttt-2", 
                            "Key": "Name"
                        }
                    ], 
                    "AmiLaunchIndex": 0
                }
            ], 
            "ReservationId": "r-0c573a8b2dee0db48", 
            "Groups": [], 
            "OwnerId": "925374498059"
        }
    ]
}
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 describe-instances --filters 'Name=tag:Name,Values=*qe-hongkliu-ttt*' --output text --query 'Reservations[*].Instances[*].InstanceId'
i-0f6469875f9e471d3	i-048c94c680090ce7d
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 describe-instances --filters 'Name=tag:Name,Values=*qe-hongkliu-ttt*' --output text --query 'Reservations[*].Instances[*].{Id:InstanceId, Name:PublicDnsName}'
i-0f6469875f9e471d3	ec2-54-186-191-136.us-west-2.compute.amazonaws.com
i-048c94c680090ce7d	ec2-54-200-204-22.us-west-2.compute.amazonaws.com
```

See [more examples](http://docs.aws.amazon.com/cli/latest/userguide/controlling-output.html) on query.
