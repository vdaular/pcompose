FROM golang:1.14-alpine as builder
LABEL maintainer="Antonio Mika <me@antoniomika.me>"

ENV GOCACHE /gocache
ENV CGO_ENABLED 0

WORKDIR /app

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

ARG VERSION=dev
ARG COMMIT=none
ARG DATE=unknown

RUN go install -ldflags="-s -w -X github.com/antoniomika/pcompose/cmd.Version=${VERSION} -X github.com/antoniomika/pcompose/cmd.Commit=${COMMIT} -X github.com/antoniomika/pcompose/cmd.Date=${DATE}"
RUN go test -i ./...

FROM alpine
LABEL maintainer="Antonio Mika <me@antoniomika.me>"

WORKDIR /app

RUN apk add --no-cache git docker-cli docker-compose

COPY --from=builder /app/deploy/ /app/deploy/
COPY --from=builder /go/bin/ /app/

ENTRYPOINT ["/app/pcompose"]