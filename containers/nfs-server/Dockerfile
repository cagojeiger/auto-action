ARG NFS_UTILS_VERSION=2.6.4
ARG ALPINE_VERSION=3.21

FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache nfs-utils && \
    find / -perm /6000 -type f -exec chmod a-s {} + 2>/dev/null || true && \
    rm -rf /var/cache/apk/* /tmp/*

RUN mkdir -p /export

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 2049

ENTRYPOINT ["/entrypoint.sh"]
