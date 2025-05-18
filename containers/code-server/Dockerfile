ARG CODE_SERVER_VERSION=4.100.0

# =============================================
# 1) Builder Stage
# =============================================
FROM codercom/code-server:${CODE_SERVER_VERSION} AS builder

ARG TARGETARCH

USER root

# kubectl 최신 버전 확인 및 설치
RUN KUBECTL_LATEST_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt) && \
    echo "➡️  Using kubectl version: ${KUBECTL_LATEST_VERSION}" && \
    curl -LO "https://dl.k8s.io/release/${KUBECTL_LATEST_VERSION}/bin/linux/${TARGETARCH}/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Helm 최신 버전 설치
RUN HELM_LATEST_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/') && \
    echo "➡️  Using Helm version: ${HELM_LATEST_VERSION}" && \
    HELM_FILENAME="helm-${HELM_LATEST_VERSION}-linux-${TARGETARCH}.tar.gz" && \
    curl -LO "https://get.helm.sh/${HELM_FILENAME}" && \
    tar -xzf "${HELM_FILENAME}" && \
    install -o root -g root -m 0755 "linux-${TARGETARCH}/helm" /usr/local/bin/helm && \
    rm -rf "${HELM_FILENAME}" "linux-${TARGETARCH}"

# K9s 설치
RUN echo "➡️  Using TARGETARCH: ${TARGETARCH}"
RUN K9S_LATEST_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using K9s version: ${K9S_LATEST_VERSION}" && \
    K9S_FILENAME="k9s_Linux_${TARGETARCH}.tar.gz" && \
    curl -LO "https://github.com/derailed/k9s/releases/download/${K9S_LATEST_VERSION}/${K9S_FILENAME}" && \
    tar -xzf "${K9S_FILENAME}" k9s && \
    install -o root -g root -m 0755 k9s /usr/local/bin/k9s && \
    rm -rf "${K9S_FILENAME}" k9s

# Skopeo 설치 (lework/skopeo-binary 사용)
RUN SKOPEO_LATEST_VERSION=$(curl -s https://api.github.com/repos/lework/skopeo-binary/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using Skopeo version: ${SKOPEO_LATEST_VERSION}" && \
    SKOPEO_FILENAME="skopeo-linux-${TARGETARCH}" && \
    curl -LO "https://github.com/lework/skopeo-binary/releases/download/${SKOPEO_LATEST_VERSION}/${SKOPEO_FILENAME}" && \
    install -o root -g root -m 0755 "${SKOPEO_FILENAME}" /usr/local/bin/skopeo && \
    rm -f "${SKOPEO_FILENAME}"

# MinIO Client (mc) 설치
RUN MC_LATEST_VERSION=$(curl -s https://api.github.com/repos/minio/mc/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using MinIO Client version: ${MC_LATEST_VERSION}" && \
    curl -LO "https://dl.min.io/client/mc/release/linux-${TARGETARCH}/mc" && \
    install -o root -g root -m 0755 mc /usr/local/bin/mc && \
    rm -f mc

# gomplate 설치
RUN GOMPLATE_LATEST_VERSION=$(curl -s https://api.github.com/repos/hairyhenderson/gomplate/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using gomplate version: ${GOMPLATE_LATEST_VERSION}" && \
    curl -LO "https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_LATEST_VERSION}/gomplate_linux-${TARGETARCH}" && \
    install -o root -g root -m 0755 gomplate_linux-${TARGETARCH} /usr/local/bin/gomplate && \
    rm -f gomplate_linux-${TARGETARCH}

# =============================================
# 2) Final Stage
# =============================================
FROM codercom/code-server:${CODE_SERVER_VERSION}

USER root

# 빌더 스테이지에서 설치된 툴을 최종 스테이지로 복사
COPY --from=builder /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=builder /usr/local/bin/helm   /usr/local/bin/helm
COPY --from=builder /usr/local/bin/k9s    /usr/local/bin/k9s
COPY --from=builder /usr/local/bin/skopeo /usr/local/bin/skopeo
COPY --from=builder /usr/local/bin/mc     /usr/local/bin/mc
COPY --from=builder /usr/local/bin/gomplate /usr/local/bin/gomplate

COPY gen_kube_config.sh /home/coder/gen_kube_config.sh
RUN chmod +x /home/coder/gen_kube_config.sh
RUN chown coder:coder /home/coder/gen_kube_config.sh

USER coder