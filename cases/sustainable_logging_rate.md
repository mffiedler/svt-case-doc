# [Sustainable Logging Rate](https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-15841)

## [Configure journald](https://www.freedesktop.org/software/systemd/man/journald.conf.html)

All set to 0:

```sh
# cat /etc/systemd/journald.conf
RateLimitInterval=1s
RateLimitBurst=10000
RateLimitIntervalSec=1s
```

## Reference
[1]. [Walid's doc](https://docs.google.com/document/d/1JB8GVYHrPK4TPMQnwViZNA-fdFMpYw-Upkpsa_YL2es/edit?ts=59b290ee)
