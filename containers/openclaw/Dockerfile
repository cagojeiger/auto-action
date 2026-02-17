ARG OPENCLAW_VERSION=2026.2.15

FROM node:22-bookworm-slim

ARG OPENCLAW_VERSION

# =============================================================================
# 1) Install system packages + openclaw
# =============================================================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git openssh-client ca-certificates \
      curl jq python3 \
      unzip zip \
      ffmpeg imagemagick \
      poppler-utils \
      pandoc \
      ripgrep && \
    # npm install requires git+ssh redirect (@whiskeysockets/libsignal-node)
    git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" && \
    git config --global url."https://github.com/".insteadOf "git@github.com:" && \
    npm install -g openclaw@${OPENCLAW_VERSION} && \
    npm cache clean --force && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# 2) Install GitHub CLI (gh) - not available in Debian bookworm repos
# =============================================================================
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# 3) Security: run as non-root
# =============================================================================
RUN usermod -l openclaw -d /home/openclaw -m node && \
    groupmod -n openclaw node && \
    mkdir -p /home/openclaw/.openclaw && \
    chown -R openclaw:openclaw /home/openclaw
USER openclaw
WORKDIR /home/openclaw

ENV HOME=/home/openclaw
ENV NODE_ENV=production

EXPOSE 18789

# Start gateway with LAN bind for container access
# --allow-unconfigured: allow startup without AI model keys (configure via Control UI)
CMD ["openclaw", "gateway", "--allow-unconfigured", "--bind", "lan", "--port", "18789"]
