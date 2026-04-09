FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY go.mod .
COPY main.go .
RUN CGO_ENABLED=0 go build -o graceful-demo .

FROM alpine:3.21
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/graceful-demo /usr/local/bin/graceful-demo
ENTRYPOINT ["graceful-demo"]
