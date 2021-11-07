# syntax=docker/dockerfile:1
FROM golang:alpine AS builder
WORKDIR /go/src/mypackage/myapp/
COPY hello.go ./
RUN go mod init && \
    go get -d -v && \
    CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /go/bin/hello

FROM scratch
COPY --from=builder /go/bin/hello /go/bin/hello
EXPOSE 8080
ENTRYPOINT ["/go/bin/hello"]