# [Protocol Buffers](https://developers.google.com/protocol-buffers/)

## Doc

* [Developer Guide](https://developers.google.com/protocol-buffers/docs/overview)
* [Protocol Buffer Language Guide](https://developers.google.com/protocol-buffers/docs/proto)

## [golang with protocol buffer 3](https://developers.google.com/protocol-buffers/docs/gotutorial)

Test repo: [proto_buffer](https://github.com/hongkailiu/test-go/tree/master/proto_buffer).

```bash
### tested on fedora 26
### define your pb messages:
$ ll proto_buffer/proto/
total 2
-rw-rw-r--. 1 hongkliu hongkliu 523 Oct 29 15:47 addressbook.proto

### download pb
$ curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v3.6.1/protoc-3.6.1-linux-x86_64.zip
$ unzip protoc-3.6.1-linux-x86_64.zip -d pb
$ cd pb

### include the binary in your ${PATH}
$ cd ~/bin/
$ ln -s ../pb/bin/protoc protoc

### download pb golang plugin
$ go get -u github.com/golang/protobuf/protoc-gen-go
$ which protoc-gen-go
~/go/bin/protoc-gen-go

$ go get github.com/hongkailiu/test-go
$ cd $GOPATH/src/github.com/hongkailiu/test-go
$ mkdir -p ./proto_buffer/gen
$ protoc -I=./proto_buffer/ --go_out=./proto_buffer/gen ./proto_buffer/proto/addressbook.proto
$ tree ./proto_buffer/gen/
./proto_buffer/gen/
└── proto
    └── addressbook.pb.go

## Then see how to use the generated code in the unit tests

```


## Use pb to transfer data
TODO