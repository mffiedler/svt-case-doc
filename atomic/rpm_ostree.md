# [RPM-OSTREE](http://www.projectatomic.io/docs/os-updates/)

On Atomic Host, <code>rpm-ostree</code> is integrated into <code>atomic host</code> command.

```sh
[fedora@ip-172-31-25-0 ~]$ rpm-ostree --version
rpm-ostree:
 Version: 2017.8
 Git: c382192257aafac720be38fdd38bfcaa84fd98c2
 Features:
  - compose

# #check configuration
[fedora@ip-172-31-25-0 ~]$ cat /etc/ostree/remotes.d/fedora-atomic.conf 
[remote "fedora-atomic"]
url=https://kojipkgs.fedoraproject.org/atomic/26/
gpg-verify=true
gpgkeypath=/etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-26-primary
```

## 
