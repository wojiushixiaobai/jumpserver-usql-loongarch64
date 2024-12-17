ARG GO_VERSION=1.23

FROM cr.loongnix.cn/library/golang:${GO_VERSION}-buster AS builder

ARG GORELEASER_VERSION=latest

RUN --mount=type=cache,target=/go/pkg/mod \
    set -ex; \
    go install github.com/goreleaser/goreleaser/v2@${GORELEASER_VERSION}

ARG VERSION=v0.0.5

ARG WORKDIR=/opt/usql

RUN set -ex; \
    git clone -b ${VERSION} --depth=1 https://github.com/jumpserver-dev/usql ${WORKDIR}

ADD .goreleaser.yml /opt/.goreleaser.yml
WORKDIR ${WORKDIR}

RUN --mount=type=cache,target=/go/pkg/mod \
    set -ex; \
    goreleaser --config /opt/.goreleaser.yml release --skip=publish --clean

FROM cr.loongnix.cn/library/debian:buster-slim

ARG WORKDIR=/opt/usql

WORKDIR ${WORKDIR}

COPY --from=builder ${WORKDIR}/dist ${WORKDIR}/dist

VOLUME /dist

CMD cp -rf dist/* /dist/