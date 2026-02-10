ARG RCLONE_VERSION=1.73.0
ARG ALPINE_VERSION=3.21

# =============================================
# 1) Builder Stage
# =============================================
FROM alpine:${ALPINE_VERSION} AS builder

ARG RCLONE_VERSION
ARG TARGETARCH

RUN apk add --no-cache curl unzip && \
    echo "➡️  Downloading rclone v${RCLONE_VERSION} for linux/${TARGETARCH}" && \
    curl -fsSL -O "https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-${TARGETARCH}.zip" && \
    curl -fsSL -O "https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/SHA256SUMS" && \
    grep "rclone-v${RCLONE_VERSION}-linux-${TARGETARCH}.zip" SHA256SUMS | sha256sum -c - && \
    unzip "rclone-v${RCLONE_VERSION}-linux-${TARGETARCH}.zip" && \
    install -m 0755 "rclone-v${RCLONE_VERSION}-linux-${TARGETARCH}/rclone" /usr/local/bin/rclone && \
    rm -rf rclone-* SHA256SUMS

# =============================================
# 2) Final Stage
# =============================================
FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache \
        ca-certificates \
        tzdata && \
    find / -perm /6000 -type f -exec chmod a-s {} + 2>/dev/null || true && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

COPY --from=builder /usr/local/bin/rclone /usr/local/bin/rclone

# OpenShift arbitrary UID: group-root(0) 소유 + group writable 필수
RUN addgroup -g 1001 fetcher && \
    adduser -u 1001 -G fetcher -D -s /sbin/nologin fetcher && \
    mkdir -p /data /tmp/rclone && \
    chown -R fetcher:0 /data /tmp/rclone && \
    chmod -R g+rwx /data /tmp/rclone

USER 1001

ENV RCLONE_CONFIG=/tmp/rclone/rclone.conf \
    XDG_CONFIG_HOME=/tmp/rclone

WORKDIR /data

ENTRYPOINT ["rclone"]
