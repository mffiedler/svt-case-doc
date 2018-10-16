# code-generator

## doc

* https://blog.openshift.com/kubernetes-deep-dive-code-generation-customresources/
* https://github.com/openshift-evangelists/crd-code-generation

## How2Use

Example repo: [codegen](https://github.com/hongkailiu/test-go/tree/master/codegen)

```bash
$ go get github.com/hongkailiu/test-go
$ cd ${GOPATH}/src/github.com/hongkailiu/test-go

$ make code-gen-clean
$ make code-gen

$ oc new-project ttt
$ oc create -f codegen/artifacts/crd.yaml
$ oc create -n ttt -f codegen/artifacts/cr.yaml

$ make build-code-gen

$ ./build/example -kubeconfig ~/.kube/config
svtGo example with Size 2

### clean up
$ oc delete -n ttt -f codegen/artifacts/cr.yaml
$ oc delete -f codegen/artifacts/crd.yaml
$ oc delete project ttt

```


## Debugging

```bash
### versions have to match
cat glide.yaml
- package: k8s.io/client-go
  version: kubernetes-1.12.1
- package: k8s.io/code-generator
  version: kubernetes-1.12.1
```

If you hit `undefined: strings.Builder`:

```bash
# make build-code-gen
./script/ci/build-code-gen.sh
# github.com/hongkailiu/test-go/vendor/k8s.io/client-go/transport
vendor/k8s.io/client-go/transport/round_trippers.go:437:9: undefined: strings.Builder
make: *** [build-code-gen] Error 2

###Make sure your go lang with 1.10+
###https://stackoverflow.com/questions/48978414/golang-strings-builder-type-undefined

```
