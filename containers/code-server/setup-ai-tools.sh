#!/bin/bash
# AI 코딩 도구 설치 (Pi Coding Agent)
# PVC 환경: 첫 부팅 시 설치, 이후 skip (자동 업데이트에 위임)
# 각 도구는 독립적으로 설치 — 하나가 실패해도 다른 도구 설치에 영향 없음

# Pi Coding Agent 설치 (npm 전역, --ignore-scripts 권장)
# 바이너리 pi 는 $NPM_CONFIG_PREFIX/bin (=$HOME/.npm-global/bin) 에 설치되어 PATH로 잡힘
if ! command -v pi &>/dev/null; then
	echo "⏳ Installing Pi Coding Agent..."
	if npm install -g --ignore-scripts @earendil-works/pi-coding-agent; then
		echo "✓ Pi installed: $(pi --version 2>/dev/null || echo 'installed')"
	else
		echo "⚠ Pi installation failed (will retry on next restart)"
	fi
else
	echo "✓ Pi already installed: $(pi --version 2>/dev/null || echo 'present')"
fi
