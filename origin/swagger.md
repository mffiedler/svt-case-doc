# Swagger

## Doc

[k8s uses goswagger](https://goswagger.io/#who-is-using-this-project)

* [swagger.io](https://swagger.io/docs/specification/about/)
* [goswagger.io](https://goswagger.io/), [go-swagger@github](https://github.com/go-swagger/go-swagger)
* [hello-world.blog](https://ops.tips/blog/a-swagger-golang-hello-world/)


## [Installation](https://goswagger.io/install.html)

```bash
### install from source
$ go get -u github.com/go-swagger/go-swagger/cmd/swagger
$ swagger version
dev
```

## Example

```bash
$ go get github.com/hongkailiu/test-go/swagger
$ cd $GOPATH/src/github.com/hongkailiu/test-go
### remove the files and folders in swagger/swagger EXCEPT swagger.yml
### generate the code again
$ make gen-swagger
$ make build-swagger
$ ./build/hello-swagger 


```

The magic is `swagger.yml` file.

## Troubleshooting

spec version

```bash
### https://github.com/hongkailiu/test-go/blob/master/glide.yaml#L10-L11
vi glide.yaml
- package: github.com/go-openapi/spec
  version: ^0.16.0

```