# Web Console

It is installed by default value (true) of `openshift_web_console_install`.

## Remove

Rerun the playbook with `openshift_web_console_install=false`:

```
# ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/openshift-web-console/config.yml 
```
