# AMQ

## Doc

* [Apache.ActiveMQ](http://activemq.apache.org/)
* https://access.redhat.com/documentation/en-us/red_hat_amq/6.3/
* [installation](https://access.redhat.com/documentation/en-us/red_hat_jboss_a-mq/6.3/html/installation_guide/installingzip)

## Apache ActiveMQ

[Installation](http://activemq.apache.org/getting-started.html)

```sh
root@ip-172-31-11-25: ~/amq/apache-activemq-5.15.4/bin # ./activemq start
INFO: Loading '/root/amq/apache-activemq-5.15.4//bin/env'
INFO: Using java '/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.172-1.b11.el7.x86_64/bin/java'
INFO: Starting - inspect logfiles specified in logging.properties and log4j.properties to get details
INFO: pidfile created : '/root/amq/apache-activemq-5.15.4//data/activemq.pid' (pid '3258')

# ss -tnlp | grep 3258
LISTEN     0      50          :::8161                    :::*                   users:(("java",pid=3258,fd=142))
LISTEN     0      50          :::45189                   :::*                   users:(("java",pid=3258,fd=13))
LISTEN     0      128         :::5672                    :::*                   users:(("java",pid=3258,fd=130))
LISTEN     0      128         :::61613                   :::*                   users:(("java",pid=3258,fd=131))
LISTEN     0      50          :::61614                   :::*                   users:(("java",pid=3258,fd=133))
LISTEN     0      128         :::61616                   :::*                   users:(("java",pid=3258,fd=129))
LISTEN     0      128         :::1883                    :::*                   users:(("java",pid=3258,fd=132))

```

Open port 8161 and port 61613 for inbound traffic for the security group used for the ec2 instance.

[Client library](http://activemq.apache.org/cross-language-clients.html): [go-stomp](https://github.com/go-stomp/stomp)

[my-code-example](https://github.com/hongkailiu/test-go/blob/master/stomp/main.go)

```sh
$ go build -o build/stomp ./stomp/
$ ./build/stomp -server ec2-54-201-211-200.us-west-2.compute.amazonaws.com:61613
```

TODO

* persistent msg: https://activemq.apache.org/stomp.html
* where are the data stored on the server? Search for `persistenceAdapter` section in `conf/activemq.xml`.

## JBoss AMQ

```sh
# unzip jboss-a-mq-6.3.0.redhat-187.zip 
# cd jboss-a-mq-6.3.0.redhat-187/
# vi etc/users.properties 
# ./bin/start

```

## Template on OCP

```sh
# oc get template -n openshift | grep amq
```

## Benchmarks

* https://github.com/romankhar/IBM-MQ-vs-ActiveMQ-peformance-test
* https://github.com/hinunbi/a-mq-bmt
