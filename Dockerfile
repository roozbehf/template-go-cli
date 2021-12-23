# syntax=docker/dockerfile:1
FROM golang:1.17 AS builder
WORKDIR /go/template-go-cli
COPY . .
RUN make go-test
RUN make go-build-docker

FROM alpine:3.13.5  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/template-go-cli/bin/go-cli .
# Add other directories as needed
# COPY --from=builder /go/template-go-cli/config/* .
ENTRYPOINT ["/root/go-cli"]
