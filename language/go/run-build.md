# Run build 方案

```shell
docker run -it \
  --name=go-builder \
  -v /data/go/pkg:/go/pkg \
  -w /go/src \
  golang:1.22.12-alpine3.18 \
  go build -o /go/bin/hello hello.go
```