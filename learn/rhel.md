# RHEL

## [bash-completion](https://www.cyberciti.biz/faq/fedora-redhat-scientific-linuxenable-bash-completion/)

```sh
# yum install bash-completion bash-completion-extras
```

## Logging
logging docs on fedora: [here](https://docs.fedoraproject.org/f27/system-administrators-guide/monitoring-and-automation/Viewing_and_Managing_Log_Files.html).

Logging Services: journald, rsyslogd

```sh
# systemctl list-units | grep syslog
rsyslog.service                                     loaded active running   System Logging Service
# systemctl list-units | grep journal
systemd-journal-flush.service                       loaded active exited    Flush Journal to Persistent Storage
systemd-journald.service                            loaded active running   Journal Service
systemd-journald.socket                             loaded active running   Journal Socket
```


Notice that `journald` have more messages than `rsyslogd`.

|                              | rsyslogd                                | journald                                                                          |
|------------------------------|-----------------------------------------|-----------------------------------------------------------------------------------|
| content                      | Syslog messages                         | Syslog messages, kernel log messages, boot messages, stdin/stderr of all services |
| conf file                    | /etc/rsyslog.conf                       | /etc/rsyslog.conf                                                                 |
| persistent by default        | saved in /var/log folder with logrotate | no                                                                                |
| default message store format | unstructured                            | structured, indexed binary                                                        |
| cli to write                 | logger                                  | logger, systemd-cat                                                               |

Run `logger "test msg 001"`, then we can get log the entry from `tail -f /var/log/messsages` and `journalctl -f` because both of them receive *Syslog messages*. Command `systemd-cat` (eg, `echo test msg 001 | systemd-cat`) writes only to `journald` and since `rsyslogd` is configured to import logs from `journald`, we can see the log entry in both too.

### rsyslog

The conf file `/etc/rsyslog.conf` specify global directives, modules, and rules that consist of filter and action parts.

```sh
###check the following pages for log format
### http://www.rsyslog.com/doc/v8-stable/configuration/templates.html
### http://www.rsyslog.com/doc/master/configuration/properties.html
# grep " format" /etc/rsyslog.conf -A1
# Use default timestamp format
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
# grep "secure" /etc/rsyslog.conf 
authpriv.*                                              /var/log/secure
# head -n 1 /var/log/secure
Jan 29 19:22:54 ip-172-31-21-62 sshd[2197]: reverse mapping checking getaddrinfo for hn.kd.ny.adsl [125.44.139.5] failed - POSSIBLE BREAK-IN ATTEMPT!
```

Add a rule for debug:

```sh
# echo "*.debug /var/log/messages-debug" > /etc/rsyslog.d/debug.conf
# systemctl restart rsyslog.service
# logger -p user.debug "debug by me"
# tail -f /var/log/messages
...
Feb  4 10:24:13 ip-172-31-21-62 ec2-user: debug by me
```

Log rotation:

```sh
# ll /var/log/messages*
-rw-------. 1 root root   3339 Feb  4 11:01 /var/log/messages
-rw-------. 1 root root 305441 Sep 18 11:16 /var/log/messages-20170918
-rw-------. 1 root root 371124 Sep 27 09:31 /var/log/messages-20170927
-rw-------. 1 root root 224415 Jan 29 19:19 /var/log/messages-20180129
-rw-------. 1 root root 288795 Feb  4 10:27 /var/log/messages-20180204

### /etc/logrotate.conf has the default log-rotation settings.
# cat  /etc/logrotate.d/syslog 
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
    missingok
    sharedscripts
    postrotate
	/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}

```

### journald

```sh
# journalctl | tail -1
Feb 04 15:10:06 ip-172-31-21-62.us-west-2.compute.internal systemd[1]: Starting Session 8 of user ec2-user.
```

The fields from `journald` look quite similar to ones from `rsyslogd`. How to use `journalctl` to filter out logs is shown [here](https://docs.fedoraproject.org/f27/system-administrators-guide/monitoring-and-automation/Viewing_and_Managing_Log_Files.html#s1-Using_the_Journal).

### [Interaction between journald and rsyslogd](https://docs.fedoraproject.org/f27/system-administrators-guide/monitoring-and-automation/Viewing_and_Managing_Log_Files.html#s1-interaction_of_rsyslog_and_journal)

By default, `rsyslogd` is configured to import logs from `journald`:

```sh
# grep -i journal /etc/rsyslog.conf | grep "^[^#;]"
$ModLoad imjournal # provides access to the systemd journal
$IMJournalStateFile imjournal.state
```



## More reading

* [Syslog messages and Syslog protocol](https://blog.rapid7.com/2017/05/24/what-is-syslog/)
