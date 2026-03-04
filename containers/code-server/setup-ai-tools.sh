#!/bin/bash
# AI 코딩 도구 설치 (Claude Code, OpenCode)
# PVC 환경: 첫 부팅 시 설치, 이후 skip (자동 업데이트에 위임)
# 각 도구는 독립적으로 설치 — 하나가 실패해도 다른 도구 설치에 영향 없음

# Claude Code 설치 (native installer)
if ! command -v claude &>/dev/null; then
	echo "⏳ Installing Claude Code..."
	if curl -fsSL https://claude.ai/install.sh | bash; then
		echo "✓ Claude Code installed: $(claude --version 2>/dev/null || echo 'installed')"
	else
		echo "⚠ Claude Code installation failed (will retry on next restart)"
	fi
else
	echo "✓ Claude Code already installed: $(claude --version 2>/dev/null || echo 'present')"
fi

# OpenCode 설치
if ! command -v opencode &>/dev/null; then
	echo "⏳ Installing OpenCode..."
	if curl -fsSL https://opencode.ai/install | bash; then
		echo "✓ OpenCode installed"
	else
		echo "⚠ OpenCode installation failed (will retry on next restart)"
	fi
else
	echo "✓ OpenCode already installed"
fi
