#!/bin/bash
set -e

# AI 코딩 도구 설치 (Claude Code, OpenCode)
# PVC 환경: 첫 부팅 시 설치, 이후 skip (자동 업데이트에 위임)

# Claude Code 설치 (native installer)
if ! command -v claude &>/dev/null; then
	echo "⏳ Installing Claude Code..."
	curl -fsSL https://claude.ai/install.sh | bash
	echo "✓ Claude Code installed: $(claude --version 2>/dev/null || echo 'installed')"
else
	echo "✓ Claude Code already installed: $(claude --version 2>/dev/null || echo 'present')"
fi

# OpenCode 설치
if ! command -v opencode &>/dev/null; then
	echo "⏳ Installing OpenCode..."
	curl -fsSL https://opencode.ai/install | bash
	echo "✓ OpenCode installed"
else
	echo "✓ OpenCode already installed"
fi
