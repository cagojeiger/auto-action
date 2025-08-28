ARG CODE_SERVER_VERSION=4.102.2

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

# ArgoCD CLI 설치
RUN ARGOCD_LATEST_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using ArgoCD version: ${ARGOCD_LATEST_VERSION}" && \
    curl -LO "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_LATEST_VERSION}/argocd-linux-${TARGETARCH}" && \
    install -o root -g root -m 0755 argocd-linux-${TARGETARCH} /usr/local/bin/argocd && \
    rm -f argocd-linux-${TARGETARCH}

# jq 설치
RUN JQ_LATEST_VERSION=$(curl -s https://api.github.com/repos/jqlang/jq/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using jq version: ${JQ_LATEST_VERSION}" && \
    curl -LO "https://github.com/jqlang/jq/releases/download/${JQ_LATEST_VERSION}/jq-linux-${TARGETARCH}" && \
    install -o root -g root -m 0755 jq-linux-${TARGETARCH} /usr/local/bin/jq && \
    rm -f jq-linux-${TARGETARCH}

# yq 설치
RUN YQ_LATEST_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using yq version: ${YQ_LATEST_VERSION}" && \
    curl -LO "https://github.com/mikefarah/yq/releases/download/${YQ_LATEST_VERSION}/yq_linux_${TARGETARCH}" && \
    install -o root -g root -m 0755 yq_linux_${TARGETARCH} /usr/local/bin/yq && \
    rm -f yq_linux_${TARGETARCH}

# GitHub CLI (gh) 설치
RUN GH_LATEST_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4 | sed 's/^v//') && \
    echo "➡️  Using gh version: ${GH_LATEST_VERSION}" && \
    GH_FILENAME="gh_${GH_LATEST_VERSION}_linux_${TARGETARCH}.tar.gz" && \
    curl -LO "https://github.com/cli/cli/releases/download/v${GH_LATEST_VERSION}/${GH_FILENAME}" && \
    tar -xzf "${GH_FILENAME}" && \
    install -o root -g root -m 0755 "gh_${GH_LATEST_VERSION}_linux_${TARGETARCH}/bin/gh" /usr/local/bin/gh && \
    rm -rf "${GH_FILENAME}" "gh_${GH_LATEST_VERSION}_linux_${TARGETARCH}"

# ripgrep (rg) 설치
RUN RG_LATEST_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using ripgrep version: ${RG_LATEST_VERSION}" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        RG_ARCH="x86_64-unknown-linux-musl"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        RG_ARCH="aarch64-unknown-linux-gnu"; \
    fi && \
    RG_FILENAME="ripgrep-${RG_LATEST_VERSION}-${RG_ARCH}.tar.gz" && \
    curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/${RG_LATEST_VERSION}/${RG_FILENAME}" && \
    tar -xzf "${RG_FILENAME}" && \
    install -o root -g root -m 0755 "ripgrep-${RG_LATEST_VERSION}-${RG_ARCH}/rg" /usr/local/bin/rg && \
    rm -rf "${RG_FILENAME}" "ripgrep-${RG_LATEST_VERSION}-${RG_ARCH}"

# Go 설치
RUN GO_LATEST_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1) && \
    echo "➡️  Using Go version: ${GO_LATEST_VERSION}" && \
    GO_FILENAME="${GO_LATEST_VERSION}.linux-${TARGETARCH}.tar.gz" && \
    curl -LO "https://go.dev/dl/${GO_FILENAME}" && \
    tar -C /usr/local -xzf "${GO_FILENAME}" && \
    rm -f "${GO_FILENAME}"

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
COPY --from=builder /usr/local/bin/argocd /usr/local/bin/argocd
COPY --from=builder /usr/local/bin/jq     /usr/local/bin/jq
COPY --from=builder /usr/local/bin/yq     /usr/local/bin/yq
COPY --from=builder /usr/local/bin/gh     /usr/local/bin/gh
COPY --from=builder /usr/local/bin/rg     /usr/local/bin/rg
COPY --from=builder /usr/local/go         /usr/local/go


# Node.js 최신 버전 설치 (NodeSource 사용) - Python3도 함께 설치됨
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# pipx, bash-completion, tig, fzf, make, tree 설치 (시스템 패키지로 설치 - Debian 12의 권장 방법)
RUN apt-get update && apt-get install -y pipx bash-completion tig fzf make tree && \
    rm -rf /var/lib/apt/lists/*

# 스크립트들 복사
COPY gen_kube_config.sh /tmp/gen_kube_config.sh
COPY setup-npm-global.sh /tmp/setup-npm-global.sh
COPY install-claude-code.sh /tmp/install-claude-code.sh
COPY setup-python-pipx.sh /tmp/setup-python-pipx.sh
COPY setup-go.sh /tmp/setup-go.sh

# 실행 권한 부여 및 소유권 설정
RUN chmod +x /tmp/*.sh && chown coder:coder /tmp/*.sh

# 환경 변수 설정 (빌드 시점에 고정)
ENV NPM_CONFIG_PREFIX="/home/coder/.npm-global"
ENV PIPX_HOME="/home/coder/.local/pipx"
ENV PIPX_BIN_DIR="/home/coder/.local/bin"
ENV PATH="/usr/local/go/bin:/home/coder/.local/bin:/home/coder/.npm-global/bin:${PATH}"

# =============================================
# 3) VS Code Extensions (Offline Support)
# =============================================

# Cache busting for latest extension versions
ARG CACHEBUST=1
RUN echo "➡️  Extension cache bust: ${CACHEBUST}"

# Download VS Code extensions for offline installation
RUN mkdir -p /home/coder/offline-extensions && \
    cd /home/coder/offline-extensions && \
    echo "➡️  Downloading VS Code extensions for offline use..." && \
    # Continue AI extension
    curl -L -o continue.vsix.gz \
    "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/Continue/vsextensions/continue/latest/vspackage" && \
    gunzip continue.vsix.gz && \
    echo "✅ Continue extension downloaded ($(du -h continue.vsix | cut -f1))" && \
    # Create installation script
    cat > install-continue.sh << 'EOF'
#!/bin/bash
echo "Installing Continue extension from offline VSIX..."
code-server --install-extension /home/coder/offline-extensions/continue.vsix
if [ $? -eq 0 ]; then
    echo "✅ Continue extension installed successfully!"
    echo "📋 Installed extensions:"
    code-server --list-extensions
else
    echo "❌ Installation failed"
    exit 1
fi
EOF

# Make script executable and create README
RUN chmod +x /home/coder/offline-extensions/install-continue.sh && \
    cd /home/coder/offline-extensions && \
    cat > README.md << 'EOF'
# Offline VS Code Extensions

This directory contains pre-downloaded VS Code extensions for offline installation.

## Available Extensions
- `continue.vsix` - Continue AI code assistant (Latest version)

## Installation Methods

### Method 1: Using the install script
```bash
./install-continue.sh
```

### Method 2: Manual installation
```bash
code-server --install-extension /home/coder/offline-extensions/continue.vsix
```

### Method 3: Through VS Code UI
1. Open Extensions panel (Ctrl+Shift+X)
2. Click "..." menu
3. Select "Install from VSIX..."
4. Navigate to `/home/coder/offline-extensions/`
5. Select `continue.vsix`

## Verify Installation
```bash
code-server --list-extensions
```

## Notes
- Extensions installed from VSIX files have auto-update disabled
- This allows for consistent versions in offline environments
- Re-run the installation script to update to newer versions
EOF

# Set proper ownership for coder user
RUN chown -R coder:coder /home/coder/offline-extensions

# coder 유저로 전환
USER coder
