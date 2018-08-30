# AMQ

## Doc

* [Apache.ActiveMQ](http://activemq.apache.org/)
* https://access.redhat.com/documentation/en-us/red_hat_amq/6.3/
* [installation](https://access.redhat.com/documentation/en-us/red_hat_jboss_a-mq/6.3/html/installation_guide/installingzip)
* [MQs](https://blog.akquinet.de/2017/02/22/activemq-confusion-and-what-comes-with-your-jboss-eap-wildfly/), [AMQ7: component version](https://access.redhat.com/articles/3188232), [AMQ6: component version](https://access.redhat.com/articles/3188202)
* [durable queue/topic](http://activemq.apache.org/how-do-durable-queues-and-topics-work.html), [Christian Posta's blog](http://blog.christianposta.com/guaranteed-messaging-for-topics-the-jms-spec-and-activemq/)

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

Open port 8161 (mng console; admin/admin) and port 61613 (stomp) for inbound traffic for the security group used for the ec2 instance.

[Client library](http://activemq.apache.org/cross-language-clients.html): [go-stomp](https://github.com/go-stomp/stomp)

[my-code-example](https://github.com/hongkailiu/test-go/blob/master/stomp/main.go)

```sh
$ go build -o build/stomp ./stomp/
$ ./build/stomp -server ec2-54-201-211-200.us-west-2.compute.amazonaws.com:61613
```

Observe:

* persistent msg: [`persistent:true`](https://activemq.apache.org/stomp.html)
* data store: Search for `persistenceAdapter` section in `conf/activemq.xml`.

## JBoss AMQ

```sh
# unzip jboss-a-mq-6.3.0.redhat-187.zip 
# cd jboss-a-mq-6.3.0.redhat-187/
# vi etc/users.properties 
# ./bin/start
### get jboss pid
# jps -lv | grep karaf

# ss -tnlp | grep 3385
LISTEN     0      1         ::ffff:127.0.0.1:39838                   :::*                   users:(("java",pid=3385,fd=233))
LISTEN     0      50          :::8101                    :::*                   users:(("java",pid=3385,fd=253))
LISTEN     0      128         :::5672                    :::*                   users:(("java",pid=3385,fd=311))
LISTEN     0      50          :::1099                    :::*                   users:(("java",pid=3385,fd=244))
LISTEN     0      50          :::35437                   :::*                   users:(("java",pid=3385,fd=26))
LISTEN     0      50          :::61614                   :::*                   users:(("java",pid=3385,fd=315))
LISTEN     0      128         :::61616                   :::*                   users:(("java",pid=3385,fd=309))
LISTEN     0      50          :::8181                    :::*                   users:(("java",pid=3385,fd=254))
LISTEN     0      128         :::1883                    :::*                   users:(("java",pid=3385,fd=314))
LISTEN     0      50          :::44444                   :::*                   users:(("java",pid=3385,fd=245))

# grep activemq etc/system.properties 
activemq.port = 61616
activemq.host = localhost
activemq.url = tcp://${activemq.host}:${activemq.port}

```

Observe:

* JBoss AMQ is embeded in [karaf](https://karaf.apache.org/), [fuse](https://www.redhat.com/en/technologies/jboss-middleware/fuse), [fabric](https://access.redhat.com/documentation/en-us/red_hat_jboss_a-mq/6.3/html/fabric_guide/).
* Port 8181 is the [mnt console](https://access.redhat.com/documentation/en-us/red_hat_jboss_a-mq/6.3/html/management_console_user_guide/fmcug_introduction_accessing) and login with `admin/admin` by default. The Web UI looks more advanced.
* go-stomp is not working yet with JBoss AMQ 6.3: because stomp is not enabled by default (compare `transportConnectors` section between jboss's `etc/activemq.xml` and apache's `conf/activemq.xml`).

TBD:

* Which version of JBoss AMQ is the testing target? 6.3 vs 7.2
* Data store engine: [depending on 6.3 or 7.2, many supported, journal, jdbc ...](https://access.redhat.com/documentation/en-us/red_hat_amq/7.2/html/migrating_to_red_hat_amq_7/message_persistence)
* Msg model (e2e vs pub/sub) and Protocol (many are supported, openwire,stomp ...)?

## [JBoss AMQ on OCP](https://access.redhat.com/documentation/en-us/red_hat_jboss_a-mq/6.3/html/red_hat_jboss_a-mq_for_openshift/)

```sh
# oc get template -n openshift | grep amq
...
amq63-persistent
...
eap71-amq-persistent-s2i
...

# oc process --parameters openshift//amq63-persistent
# oc process --parameters openshift//eap71-amq-persistent-s2i
```

```sh
# oc new-project ttt
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/amq63-persistent-ttt.yaml -p MQ_PROTOCOL=openwire,amqp,stomp,mqtt -p VOLUME_CAPACITY=10Gi -p MQ_USERNAME=redhat -p MQ_PASSWORD=redhat -p AMQ_QUEUE_MEMORY_LIMIT=1mb -p STORAGE_CLASS_NAME=glusterfs-storage | oc create -f -

# oc get svc broker-amq-tcp
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
broker-amq-tcp   ClusterIP   172.25.151.74   <none>        61616/TCP   2h

```

Observe:

* [ReadWriteMany](https://github.com/hongkailiu/svt-case-doc/blob/master/files/amq63-persistent-ttt.yaml#L268) support of PVC is required since the PVC is used by 2 DCs.
* mng console: find it on the Web UI. See more on jolokia: [link1](https://developers.redhat.com/blog/2017/08/16/troubleshooting-java-applications-on-openshift/),
[link2](https://developers.redhat.com/blog/2016/03/30/jolokia-jvm-monitoring-in-openshift/)
* springboot for sending/receiving: [src](https://github.com/hongkailiu/test-springboot/tree/messaging-jms)
* There is a reason that no route is defined. [routers support only http(s)](https://github.com/openshift/origin/issues/3415). Potential solutions: [expose_service](https://docs.openshift.com/container-platform/3.9/dev_guide/expose_service/index.html) and [port_forwarding](https://docs.openshift.com/container-platform/3.9/dev_guide/port_forwarding.html)

## Tests

Starting with:

* JBoss AMQ 6.3 on OCP: default data store
* One benchmark tool: one protocal/one msg model

## Benchmarks

* [activemq-perf-maven-plugin](http://activemq.apache.org/performance.html)
* https://github.com/romankhar/IBM-MQ-vs-ActiveMQ-peformance-test
* https://github.com/hinunbi/a-mq-bmt

### activemq-perf-maven-plugin

```sh
###optional: build the plugin
$ git clone https://git-wip-us.apache.org/repos/asf/activemq.git
$ cd activemq
###jboss amq: component versions: https://access.redhat.com/articles/3188202
$ git checkout activemq-5.11.x
$ git fetch origin  --tags --prune
$ git checkout tags/activemq-5.11.4
$ activemq-tooling
$ mvn clean install
###run the pbenchmark
###yum install subversion
$ svn co http://svn.apache.org/repos/asf/activemq/sandbox/activemq-perftest
$ cd activemq-perftest/
### https://mvnrepository.com/artifact/org.apache.activemq.tooling/activemq-perf-maven-plugin/5.15.4
### vi pom.xml
...
<activemq-version>5.15.4</activemq-version>
...
### svc ip: 172.25.151.74
$ mvn -f ./activemq-perftest/pom.xml -Dmaven.repo.local=/repo activemq-perf:producer -Dfactory.brokerURL=tcp://172.25.151.74:61616 -Dfactory.userName=redhat -Dfactory.password=redhat -DsysTest.reportDir=/data/ -Dproducer.deliveryMode=persistent -Dfactory.clientID=my-test-producer -Dproducer.destName=topic://TEST.FOO
$ mvn -f ./activemq-perftest/pom.xml -Dmaven.repo.local=/repo activemq-perf:consumer -Dfactory.brokerURL=tcp://172.25.151.74:61616 -Dfactory.userName=redhat -Dfactory.password=redhat -DsysTest.reportDir=/data/ -Dconsumer.durable=true -Dfactory.clientID=my-test-consumer -Dconsumer.destName=topic://TEST.FOO

$ mvn -f ./activemq-perftest/pom.xml -Dmaven.repo.local=/repo activemq-perf:producer -Dfactory.brokerURL=tcp://172.25.151.74:61616 -Dfactory.userName=redhat -Dfactory.password=redhat -DsysTest.reportDir=/data/ -Dproducer.deliveryMode=persistent -Dfactory.clientID=my-test-producer -Dproducer.destName=queue://TEST.FOO
$ mvn -f ./activemq-perftest/pom.xml -Dmaven.repo.local=/repo activemq-perf:consumer -Dfactory.brokerURL=tcp://172.25.151.74:61616 -Dfactory.userName=redhat -Dfactory.password=redhat -DsysTest.reportDir=/data/ -Dconsumer.durable=true -Dfactory.clientID=my-test-consumer -Dconsumer.destName=queue://TEST.FOO
###Generated report
$ ll /data/Jms*
-rw-r--r--. 1 root root 82822 Jul 18 17:43 JmsConsumer_numClients1_numDests1_all.xml
-rw-r--r--. 1 root root 83723 Jul 18 17:47 JmsProducer_numClients1_numDests1_all.xml
```


Problems:

* `factory.clientID` seems not working. On console it is still `Client id: JmsProducer0`. Not seeing the relevant code in [src](https://git-wip-us.apache.org/repos/asf?p=activemq.git;a=blob;f=activemq-tooling/activemq-perf-maven-plugin/src/main/java/org/apache/activemq/tool/AbstractJmsClientSystem.java;h=58efb99958296f9baf84f07742a4c2e97fb4359c;hb=HEAD#l104).
* `consumer.destName=queue://TEST.FOO` seems not working:
	Found the problem in [src](https://git-wip-us.apache.org/repos/asf?p=activemq.git;a=blob;f=activemq-tooling/activemq-perf-maven-plugin/src/main/java/org/apache/activemq/tool/JmsConsumerClient.java;h=2ee01ab11b2521a7a50d4f04706ab190b148f127;hb=HEAD#l237): if durable consumer is applicable only to topic, not queue. Remove `-Dconsumer.durable=true` and then it works.

* `producer.destName=queue://TEST.FOO` does not terminate after 5 minutes (amq server in pod), message count stopped at 1.

```
$ mvn -f ./activemq-perftest/pom.xml -Dmaven.repo.local=/repo activemq-perf:consumer -Dfactory.brokerURL=tcp://172.25.151.74:61616 -Dfactory.userName=redhat -Dfactory.password=redhat -DsysTest.reportDir=/data/ -Dconsumer.durable=true -Dfactory.clientID=my-test-consumer -Dconsumer.destName=queue://TEST.FOO
[INFO] Scanning for projects...
[INFO] 
[INFO] ---------------< org.apache.activemq:activemq-perftest >----------------
[INFO] Building ActiveMQ :: Performance Test 5.7.0
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] 
[INFO] --- activemq-perf-maven-plugin:5.15.4:consumer (default-cli) @ activemq-perftest ---
[INFO] Created: org.apache.activemq.ActiveMQConnectionFactory using SPIConnectionFactory: org.apache.activemq.tool.spi.ActiveMQReflectionSPI
[INFO] Creating queue: queue://TEST.FOO
[INFO] Sampling duration: 300000 ms, ramp up: 0 ms, ramp down: 0 ms
[INFO] Sampling duration: 300000 ms, ramp up: 0 ms, ramp down: 0 ms
[INFO] Creating JMS Connection: Provider=ActiveMQ-5.15.4, JMS Spec=1.1
[INFO] Creating durable subscriber (JmsConsumer0) to: queue://TEST.FOO
Exception in thread "JmsConsumer0 Thread" java.lang.ClassCastException: org.apache.activemq.command.ActiveMQQueue cannot be cast to javax.jms.Topic
	at org.apache.activemq.tool.JmsConsumerClient.createJmsConsumer(JmsConsumerClient.java:237)
	at org.apache.activemq.tool.JmsConsumerClient.createJmsConsumer(JmsConsumerClient.java:223)
	at org.apache.activemq.tool.JmsConsumerClient.receiveAsyncTimeBasedMessages(JmsConsumerClient.java:132)
	at org.apache.activemq.tool.JmsConsumerClient.receiveMessages(JmsConsumerClient.java:53)
	at org.apache.activemq.tool.JmsConsumerClient.receiveMessages(JmsConsumerClient.java:68)
	at org.apache.activemq.tool.JmsConsumerClient.receiveMessages(JmsConsumerClient.java:73)
	at org.apache.activemq.tool.JmsConsumerSystem.runJmsClient(JmsConsumerSystem.java:73)
	at org.apache.activemq.tool.AbstractJmsClientSystem$1.run(AbstractJmsClientSystem.java:110)
	at java.lang.Thread.run(Thread.java:748)

```

## Useful commands in the test

```
# wget -r -np -nH --cut-dirs=6 -l 1 http://pbench.perf.lab.eng.bos.redhat.com/results/ansible-host/amq_test_results/pbench-user-benchmark_amq_storage_test_50_glusterfs-storage_2018.08.30T01.19.55/1/reference-result/
# grep -irn SystemTotalTP ./ | cut -f2 -d">" | cut -f1 -d"<"
# oc get projects | cut -f1 -d" " | grep -E "storage-test-amq-[0-9]+" | while read i; do oc delete project $i; done
# pbench-move-results --prefix=amq_test_results
```

```
###depolyment issue
# oc get pod --all-namespaces | grep -v Running
NAMESPACE                           NAME                                               READY     STATUS      RESTARTS   AGE
openshift-logging                   logging-curator-1535599800-6rbwl                   0/1       Completed   0          8h
NAMESPACE                           NAME                                               READY     STATUS      RESTARTS   AGE
NAMESPACE                           NAME                                               READY     STATUS      RESTARTS   AGE
storage-test-amq-103                broker-amq-1-deploy                                0/1       Error       0          20m
storage-test-amq-106                broker-amq-1-deploy                                0/1       Error       0          20m
storage-test-amq-116                broker-amq-1-deploy                                0/1       Error       0          19m
storage-test-amq-116                broker-drainer-1-deploy                            0/1       Error       0          19m
storage-test-amq-133                broker-amq-1-deploy                                0/1       Error       0          19m
storage-test-amq-133                broker-drainer-1-deploy                            0/1       Error       0          19m
storage-test-amq-160                broker-amq-1-deploy                                0/1       Error       0          19m
storage-test-amq-160                broker-drainer-1-deploy                            0/1       Error       0          19m
storage-test-amq-173                broker-amq-1-deploy                                0/1       Error       0          19m
storage-test-amq-173                broker-drainer-1-deploy                            0/1       Error       0          19m
NAMESPACE                           NAME                                               READY     STATUS      RESTARTS   AGE



###1. space issue
###2. network exception
# oc logs -n storage-test-amq-99 broker-amq-1-rfm2v --timestamps
...
2018-08-30T04:51:37.611228187Z  INFO | For help or more information please see: http://activemq.apache.org
2018-08-30T04:51:37.614876606Z  WARN | Store limit is 102400 mb (current store usage is 0 mb). The data directory: /opt/amq/data/split-1/serverData/kahadb only has 981 mb of usable space. - resetting to maximum available disk space: 981 mb
2018-08-30T04:51:37.618683007Z  WARN | Temporary Store limit is 51200 mb (current store usage is 0 mb). The data directory: /opt/amq/data/split-1/serverData only has 981 mb of usable space. - resetting to maximum available disk space: 981 mb
2018-08-30T10:43:28.516213933Z  WARN | Transport Connection to: tcp://10.178.6.1:51846 failed: java.io.EOFException
2018-08-30T10:43:28.605118472Z  WARN | Transport Connection to: tcp://10.178.6.1:51850 failed: java.io.EOFException
2018-08-30T10:48:35.855577414Z  WARN | Transport Connection to: tcp://10.178.6.1:51882 failed: java.io.EOFException
2018-08-30T10:48:37.547921493Z  WARN | Transport Connection to: tcp://10.178.6.1:51886 failed: java.io.EOFException
2018-08-30T10:53:43.958442986Z  WARN | Transport Connection to: tcp://10.178.6.1:51916 failed: java.io.EOFException
2018-08-30T10:53:44.277595429Z  WARN | Transport Connection to: tcp://10.178.6.1:51920 failed: java.io.EOFException
2018-08-30T10:58:48.629637538Z  WARN | Transport Connection to: tcp://10.178.6.1:51952 failed: java.io.EOFException
2018-08-30T10:58:48.744613303Z  WARN | Transport Connection to: tcp://10.178.6.1:51956 failed: java.io.EOFException
2018-08-30T11:03:53.084936969Z  WARN | Transport Connection to: tcp://10.178.6.1:51980 failed: java.io.EOFException
2018-08-30T11:03:53.332428517Z  WARN | Transport Connection to: tcp://10.178.6.1:51984 failed: java.io.EOFException
2018-08-30T11:08:57.30246362Z  WARN | Transport Connection to: tcp://10.178.6.1:52014 failed: java.io.EOFException
```

