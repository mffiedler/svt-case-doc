# JMeter

Use GUI only for test plan editing and debugging. Use [non-GUI mode](https://jmeter.apache.org/usermanual/get-started.html#non_gui) to do the test.


## HTTP request

Use jmeter cli

```sh
[hongkliu@hongkliu jmeter]$ ll ../jmeter
lrwxrwxrwx. 1 hongkliu hongkliu 17 Aug  9 15:36 ../jmeter -> apache-jmeter-4.0
$ git -C ~/repo/me/jmeter-test/ remote get-url origin
https://github.com/hongkailiu/jmeter-test.git
### run the test and generate the log file
$ ./bin/jmeter -n -t ~/repo/me/jmeter-test/http.google.jmx -p ~/repo/me/jmeter-test/http.google.user.properties -l /tmp/http.google.log.jtl
### use the log file to generate the dashboard
$ ./bin/jmeter -g /tmp/http.google.log.jtl -o ~/Downloads/jmeter_aaa/bbb
### This can also be done in one command:
### https://sqa.stackexchange.com/questions/18816/how-to-generate-report-dashboard-in-jmeter
### https://jmeter.apache.org/usermanual/generating-dashboard.html#report
### !!! for some reason, this command does not work.
$ ./bin/jmeter -n -t ~/repo/me/jmeter-test/http.google.jmx -p ~/repo/me/jmeter-test/http.google.user.properties -l /tmp/http.google.log.jtl -e -o ~/Downloads/jmeter_aaa/bbb/
```

See [command-line options](https://jmeter.apache.org/usermanual/get-started.html#options).

TODO: https://www.blazemeter.com/blog/3-easy-ways-to-monitor-jmeter-non-gui-test-results

## JMS