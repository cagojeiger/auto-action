ARG OPENCLAW_VERSION=2026.2.9

FROM node:22-bookworm-slim

ARG OPENCLAW_VERSION

# Install openclaw + essential agent tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git openssh-client ca-certificates \
      curl jq python3 && \
    git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" && \
    git config --global url."https://github.com/".insteadOf "git@github.com:" && \
    npm install -g openclaw@${OPENCLAW_VERSION} && \
    npm cache clean --force && \
    apt-get purge -y openssh-client && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Security: run as non-root
RUN useradd -m -s /bin/bash openclaw
USER openclaw
WORKDIR /home/openclaw

# Default state directory
ENV HOME=/home/openclaw
ENV NODE_ENV=production

EXPOSE 18789

# Start gateway with LAN bind for container access
# --allow-unconfigured: allow startup without AI model keys (configure via Control UI)
CMD ["openclaw", "gateway", "--allow-unconfigured", "--bind", "lan", "--port", "18789"]
