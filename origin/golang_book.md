# GoLang Book

* [The Go Programming Language](https://books.google.ca/books/about/The_Go_Programming_Language.html?id=SJHvCgAAQBAJ&source=kp_cover&redir_esc=y)

## Ch 1

* run ch1/dup1

```sh
### https://unix.stackexchange.com/questions/16333/how-to-signal-the-end-of-stdin-input
$ go run ./ch1/dup1/main.go
 abc
 111
 abc<ctrl+d>
 2       abc
###OR
$ echo -e "abc\n111\nabc\n" | go run ./ch1/dup1/main.go
2       abc

```
