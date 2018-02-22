# pbench-fio: 2.14 vs 3.3



```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-a1d75bd9     --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 60}}, {\"DeviceName\":\"/dev/sdf\", \"Ebs\":{\"VolumeSize\": 1000}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fio-test\"}]}]"

```
