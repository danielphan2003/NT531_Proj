FROM docker.io/library/rust:latest as build

WORKDIR /app

COPY patches ./patches

RUN \
    DEBIAN_FRONTEND=noninteractive \
    apt-get update &&\
    apt-get -y install ca-certificates tzdata

RUN \
    curl -fsSL https://github.com/szabodanika/microbin/archive/master.tar.gz | tar -zxv &&\
    mv microbin-master/* . &&\
    rm -rf microbin-master &&\
    git apply patches/0001-custom-sqlite-db-healthcheck-periodic-db-sync.patch

RUN \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    cargo build --release

# https://hub.docker.com/r/bitnami/minideb
FROM docker.io/bitnami/minideb:latest

# microbin will be in /app
WORKDIR /app

RUN mkdir -p /usr/share/zoneinfo

RUN \
    DEBIAN_FRONTEND=noninteractive \
    apt-get update &&\
    apt-get -y install ca-certificates tzdata fuse3 sqlite3 &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# copy time zone info
COPY --from=build \
    /usr/share/zoneinfo \
    /usr/share/

COPY --from=build \
    /etc/ssl/certs/ca-certificates.crt \
    /etc/ssl/certs/ca-certificates.crt

COPY --from=docker.io/flyio/litefs:0.5.11 \
    /usr/local/bin/litefs \
    /usr/local/bin/litefs

ADD litefs/litefs.static-lease.yml /etc/litefs.yml

# copy built executable
COPY --from=build \
    /app/target/release/microbin \
    /usr/bin/microbin

ENTRYPOINT ["litefs", "mount"]
