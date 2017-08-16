# Ginkgo

## cli
[cli manual](http://onsi.github.io/ginkgo/#the-ginkgo-cli)

## Some features used by extended-test in origin

### [focus](http://onsi.github.io/ginkgo/#focused-specs)
The following command will run specs which matches the regex <code>Http Root handler</code>.

```sh
[hongkliu@hongkliu svt-go]$ ginkgo -v --focus="Http Root handler" extended/
```

### [precompiling test](http://onsi.github.io/ginkgo/#precompiling-tests)
build and run with precompiling test

```sh
[hongkliu@hongkliu svt-go]$ ginkgo build extended/
[hongkliu@hongkliu svt-go]$ ginkgo -v -p -stream extended/extended.test
```

### [junit xml](http://onsi.github.io/ginkgo/#generating-junit-xml-output)

