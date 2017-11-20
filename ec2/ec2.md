# EC2
ssh key: libra.pem; [ec2 instance types](https://aws.amazon.com/ec2/instance-types/)

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

### Fedora 26
List of AMIs is [here](https://alt.fedoraproject.org/cloud/).

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-2c1c0f55 \
    --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.large --key-name id_rsa_perf \
    --subnet subnet-4879292d --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 30}}]" \
    --query 'Instances[*].InstanceId' \
    --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fedora26-test\"}]}]"
```

### Standard RHEL 7.3

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-b55a51cc \
    --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.large --key-name id_rsa_perf \
    --subnet subnet-4879292d \
    --query 'Instances[*].InstanceId' \
    --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-rhel73-test\"}]}]"
```

RHEL images: 7.4 (ami-9fa343e7)

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 describe-images --owner 309956199498 --output text --region us-west-2 | grep "RHEL-7.4" | grep -v Beta
```


### Atomic Host

Fedora Atomic:

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-b11febc9 \
     --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.large --key-name id_rsa_perf \
     --subnet subnet-4879292d --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 60}}]" \
     --query 'Instances[*].InstanceId' \
     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-atomic-test\"}]}]"

```

Red Hat Atomic with gold AMI:

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-424cb83a \
    --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.large --key-name id_rsa_perf \
    --subnet subnet-4879292d \
    --query 'Instances[*].InstanceId' \
    --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-atomic-test\"}]}]"
```

### Useful commands

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-f2d3cd8b \
    --security-group-ids sg-5c5ace38 --count 2 --instance-type m4.xlarge --key-name id_rsa_perf \
    --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 60}}]" \
    --query 'Instances[*].InstanceId' \
    --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-test\"}]}]"
[
    "i-09b960edd26316b8e", 
    "i-0d11e05b64fcf6ca1"
]

(awsenv) [hongkliu@hongkliu awscli]$ aws ec2  create-tags --resources i-0f6469875f9e471d3 \
    --tags "Key=Name,Value=qe-hongkliu-ttt"

(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 describe-instances --filters 'Name=tag:Name,Values=*qe-hongkliu-ttt*' \
    --output text --query 'Reservations[*].Instances[*].InstanceId'
i-0f6469875f9e471d3	i-048c94c680090ce7d
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 describe-instances --filters 'Name=tag:Name,Values=*qe-hongkliu-ttt*' \
    --output text --query 'Reservations[*].Instances[*].{Id:InstanceId, Name:PublicDnsName}'
i-0f6469875f9e471d3	ec2-54-186-191-136.us-west-2.compute.amazonaws.com
i-048c94c680090ce7d	ec2-54-200-204-22.us-west-2.compute.amazonaws.com
```

See [more examples](http://docs.aws.amazon.com/cli/latest/userguide/controlling-output.html) on query.
