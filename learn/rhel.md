# RHEL

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

### rsyslog

The conf file `/etc/rsyslog.conf` specify global directives, modules, and rules that consist of filter and action parts.

```
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

## More reading

* [Syslog messages and Syslog protocol](https://blog.rapid7.com/2017/05/24/what-is-syslog/)
