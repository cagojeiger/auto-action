ARG CODE_SERVER_VERSION=4.109.2

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

# AWS CLI v2 설치
RUN apt-get update && apt-get install -y unzip && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        AWS_ARCH="x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        AWS_ARCH="aarch64"; \
    fi && \
    curl -LO "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" && \
    unzip -o awscli-exe-linux-${AWS_ARCH}.zip && \
    ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli && \
    rm -rf awscli-exe-linux-${AWS_ARCH}.zip aws && \
    echo "➡️  AWS CLI installed: $(aws --version)"

# Docker CLI 설치 (daemon 없이 CLI만)
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        DOCKER_ARCH="x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        DOCKER_ARCH="aarch64"; \
    fi && \
    DOCKER_VERSION=$(curl -s https://api.github.com/repos/moby/moby/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4 | sed 's/^docker-v//') && \
    echo "➡️  Using Docker version: ${DOCKER_VERSION}" && \
    curl -fsSL "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${DOCKER_VERSION}.tgz" | \
    tar -xz --strip-components=1 -C /usr/local/bin docker/docker

# Docker Compose 플러그인 설치
RUN mkdir -p /usr/local/lib/docker/cli-plugins && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        COMPOSE_ARCH="x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        COMPOSE_ARCH="aarch64"; \
    fi && \
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using Docker Compose version: ${COMPOSE_VERSION}" && \
    curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${COMPOSE_ARCH}" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Terraform 설치
RUN TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4 | sed 's/^v//') && \
    echo "➡️  Using Terraform version: ${TERRAFORM_VERSION}" && \
    curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip" && \
    unzip -o terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip && \
    install -o root -g root -m 0755 terraform /usr/local/bin/terraform && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip terraform

# Vault CLI 설치
RUN VAULT_VERSION=$(curl -s https://api.github.com/repos/hashicorp/vault/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4 | sed 's/^v//') && \
    echo "➡️  Using Vault version: ${VAULT_VERSION}" && \
    curl -LO "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${TARGETARCH}.zip" && \
    unzip -o vault_${VAULT_VERSION}_linux_${TARGETARCH}.zip && \
    install -o root -g root -m 0755 vault /usr/local/bin/vault && \
    rm -f vault_${VAULT_VERSION}_linux_${TARGETARCH}.zip vault

# SOPS 설치
RUN SOPS_VERSION=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using SOPS version: ${SOPS_VERSION}" && \
    curl -LO "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${TARGETARCH}" && \
    install -o root -g root -m 0755 sops-${SOPS_VERSION}.linux.${TARGETARCH} /usr/local/bin/sops && \
    rm -f sops-${SOPS_VERSION}.linux.${TARGETARCH}

# direnv 설치
RUN DIRENV_VERSION=$(curl -s https://api.github.com/repos/direnv/direnv/releases/latest | grep '"tag_name":' | head -n1 | cut -d'"' -f4) && \
    echo "➡️  Using direnv version: ${DIRENV_VERSION}" && \
    curl -LO "https://github.com/direnv/direnv/releases/download/${DIRENV_VERSION}/direnv.linux-${TARGETARCH}" && \
    install -o root -g root -m 0755 direnv.linux-${TARGETARCH} /usr/local/bin/direnv && \
    rm -f direnv.linux-${TARGETARCH}

# OpenCode 설치 (jq 사용 - QEMU 에뮬레이션에서 grep/cut 불안정)
RUN OPENCODE_VERSION=$(curl -s https://api.github.com/repos/anomalyco/opencode/releases/latest | jq -r '.tag_name') && \
    echo "➡️  Using OpenCode version: ${OPENCODE_VERSION}" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        OPENCODE_ARCH="x64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        OPENCODE_ARCH="arm64"; \
    fi && \
    curl -fsSL "https://github.com/anomalyco/opencode/releases/download/${OPENCODE_VERSION}/opencode-linux-${OPENCODE_ARCH}.tar.gz" | \
    tar -xz -C /tmp && \
    install -o root -g root -m 0755 /tmp/opencode /usr/local/bin/opencode

# =============================================
# 2) Final Stage
# =============================================
FROM codercom/code-server:${CODE_SERVER_VERSION}

USER root

# 빌더 스테이지에서 설치된 툴을 최종 스테이지로 복사
COPY --from=builder /usr/local/bin/kubectl   /usr/local/bin/kubectl
COPY --from=builder /usr/local/bin/helm      /usr/local/bin/helm
COPY --from=builder /usr/local/bin/k9s       /usr/local/bin/k9s
COPY --from=builder /usr/local/bin/skopeo    /usr/local/bin/skopeo
COPY --from=builder /usr/local/bin/mc        /usr/local/bin/mc
COPY --from=builder /usr/local/bin/argocd    /usr/local/bin/argocd
COPY --from=builder /usr/local/bin/jq        /usr/local/bin/jq
COPY --from=builder /usr/local/bin/yq        /usr/local/bin/yq
COPY --from=builder /usr/local/bin/gh        /usr/local/bin/gh
COPY --from=builder /usr/local/bin/rg        /usr/local/bin/rg
COPY --from=builder /usr/local/go            /usr/local/go
# AWS CLI - 디렉토리만 복사하고 심볼릭 링크는 수동 생성
# (PyInstaller 바이너리는 상대 경로로 libpython을 찾으므로 원래 위치 유지 필요)
COPY --from=builder /usr/local/aws-cli       /usr/local/aws-cli
RUN ln -s /usr/local/aws-cli/v2/current/bin/aws /usr/local/bin/aws && \
    ln -s /usr/local/aws-cli/v2/current/bin/aws_completer /usr/local/bin/aws_completer
COPY --from=builder /usr/local/bin/docker    /usr/local/bin/docker
RUN mkdir -p /usr/local/lib/docker/cli-plugins
COPY --from=builder /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose
COPY --from=builder /usr/local/bin/terraform /usr/local/bin/terraform
COPY --from=builder /usr/local/bin/vault     /usr/local/bin/vault
COPY --from=builder /usr/local/bin/sops      /usr/local/bin/sops
COPY --from=builder /usr/local/bin/direnv    /usr/local/bin/direnv
COPY --from=builder /usr/local/bin/opencode  /usr/local/bin/opencode


# Node.js 최신 버전 설치 (NodeSource 사용) - Python3도 함께 설치됨
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# pipx, bash-completion, tig, fzf, make, tree, pre-commit 설치 (시스템 패키지로 설치 - Debian 12의 권장 방법)
RUN apt-get update && apt-get install -y pipx bash-completion tig fzf make tree pre-commit && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /usr/share/oh-my-zsh && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/oh-my-zsh/custom/themes/powerlevel10k && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    rm -rf /usr/share/oh-my-zsh/.git \
           /usr/share/oh-my-zsh/custom/themes/powerlevel10k/.git \
           /usr/share/oh-my-zsh/custom/plugins/zsh-autosuggestions/.git \
           /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/.git && \
    chsh -s /usr/bin/zsh coder

# MesloLGS NF 웹폰트 설치 (powerlevel10k 아이콘 브라우저 렌더링용)
RUN mkdir -p /usr/lib/code-server/lib/vscode/out/vs/code/browser/workbench/fonts && \
    cd /usr/lib/code-server/lib/vscode/out/vs/code/browser/workbench/fonts && \
    curl -fsSLO "https://github.com/uncon/MesloLGSNF-web-fonts/raw/874c562a09457f52242b36ba5f7f2a85557131de/fonts/MesloLGS-NF-Regular.woff2" && \
    curl -fsSLO "https://github.com/uncon/MesloLGSNF-web-fonts/raw/874c562a09457f52242b36ba5f7f2a85557131de/fonts/MesloLGS-NF-Bold.woff2" && \
    curl -fsSLO "https://github.com/uncon/MesloLGSNF-web-fonts/raw/874c562a09457f52242b36ba5f7f2a85557131de/fonts/MesloLGS-NF-Italic.woff2" && \
    curl -fsSLO "https://github.com/uncon/MesloLGSNF-web-fonts/raw/874c562a09457f52242b36ba5f7f2a85557131de/fonts/MesloLGS-NF-Bold-Italic.woff2"

# @font-face CSS를 workbench.css에 append (브라우저에서 MesloLGS NF 사용 가능하게)
RUN cat >> /usr/lib/code-server/lib/vscode/out/vs/code/browser/workbench/workbench.css << 'CSSEOF'

@font-face {
    font-family: 'MesloLGS NF';
    src: url('fonts/MesloLGS-NF-Regular.woff2') format('woff2');
    font-weight: normal;
    font-style: normal;
    font-display: swap;
}
@font-face {
    font-family: 'MesloLGS NF';
    src: url('fonts/MesloLGS-NF-Bold.woff2') format('woff2');
    font-weight: bold;
    font-style: normal;
    font-display: swap;
}
@font-face {
    font-family: 'MesloLGS NF';
    src: url('fonts/MesloLGS-NF-Italic.woff2') format('woff2');
    font-weight: normal;
    font-style: italic;
    font-display: swap;
}
@font-face {
    font-family: 'MesloLGS NF';
    src: url('fonts/MesloLGS-NF-Bold-Italic.woff2') format('woff2');
    font-weight: bold;
    font-style: italic;
    font-display: swap;
}
CSSEOF

RUN mkdir -p /etc/entrypoint.d

COPY setup-zsh.sh           /etc/entrypoint.d/10-setup-zsh.sh
COPY setup-npm-global.sh    /etc/entrypoint.d/20-setup-npm-global.sh
COPY setup-go.sh            /etc/entrypoint.d/30-setup-go.sh
COPY setup-python-pipx.sh       /etc/entrypoint.d/40-setup-python-pipx.sh
COPY setup-vscode-settings.sh   /etc/entrypoint.d/50-setup-vscode-settings.sh
COPY p10k.zsh                   /etc/entrypoint.d/p10k.zsh

COPY gen_kube_config.sh     /tmp/gen_kube_config.sh
COPY install-claude-code.sh /tmp/install-claude-code.sh

RUN chmod +x /etc/entrypoint.d/*.sh /tmp/*.sh && \
    chown coder:coder /etc/entrypoint.d/* /tmp/*.sh

ENV ENTRYPOINTD=/etc/entrypoint.d
ENV NPM_CONFIG_PREFIX="/home/coder/.npm-global"
ENV PIPX_HOME="/home/coder/.local/pipx"
ENV PIPX_BIN_DIR="/home/coder/.local/bin"
ENV PATH="/usr/local/go/bin:/home/coder/.local/bin:/home/coder/.npm-global/bin:${PATH}"

# VS Code Extensions (Offline Support)
ARG CACHEBUST=1
RUN mkdir -p /tmp/extensions && \
    curl -sL "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/Continue/vsextensions/continue/latest/vspackage" | \
    gunzip > /tmp/extensions/continue.vsix

# coder 유저로 전환
USER coder
