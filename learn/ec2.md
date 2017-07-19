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
Default region name [None]: us-west-2b
Default output format [None]: json
(awsenv) [hongkliu@hongkliu awscli]$ ls ~/.aws/
config  credentials
```

## [Cli tutorial](http://docs.aws.amazon.com/cli/latest/userguide/tutorial-ec2-ubuntu.html)

