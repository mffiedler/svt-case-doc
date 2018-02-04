# RHEL

## Logging
logging docs on fedora: [here](https://docs.fedoraproject.org/f27/system-administrators-guide/monitoring-and-automation/Viewing_and_Managing_Log_Files.html).

### Logging Services: journald, rsyslogd

```sh
# systemctl list-units | grep syslog
rsyslog.service                                     loaded active running   System Logging Service
# systemctl list-units | grep journal
systemd-journal-flush.service                       loaded active exited    Flush Journal to Persistent Storage
systemd-journald.service                            loaded active running   Journal Service
systemd-journald.socket                             loaded active running   Journal Socket
```

