ARG REPO_SYNC_VERSION=0.1.0

# =============================================
# 1) Builder Stage - rclone 바이너리 다운로드
# =============================================
FROM alpine:3.23 AS builder

ARG TARGETARCH

RUN apk add --no-cache curl unzip && \
    RCLONE_VERSION=$(curl -s https://downloads.rclone.org/version.txt | awk '{print $2}' | tr -d '[:space:]') && \
    echo "➡️  Using rclone version: ${RCLONE_VERSION}" && \
    curl -LO "https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${TARGETARCH}.zip" && \
    unzip -o "rclone-${RCLONE_VERSION}-linux-${TARGETARCH}.zip" && \
    install -m 0755 "rclone-${RCLONE_VERSION}-linux-${TARGETARCH}/rclone" /usr/local/bin/rclone && \
    rm -rf "rclone-${RCLONE_VERSION}-linux-${TARGETARCH}"*

# =============================================
# 2) Final Stage
# =============================================
FROM alpine:3.23

RUN apk add --no-cache \
    bash \
    git \
    openssh-client \
    rsync \
    ca-certificates \
    tini

COPY --from=builder /usr/local/bin/rclone /usr/local/bin/rclone

COPY entrypoint.sh    /usr/local/bin/entrypoint.sh
COPY fetch-git.sh     /usr/local/bin/fetch-git.sh
COPY fetch-rclone.sh  /usr/local/bin/fetch-rclone.sh
COPY fetch-rsync.sh   /usr/local/bin/fetch-rsync.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
             /usr/local/bin/fetch-git.sh \
             /usr/local/bin/fetch-rclone.sh \
             /usr/local/bin/fetch-rsync.sh

ENV SYNC_MODE="pull" \
    DEST_PATH="/data"

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
