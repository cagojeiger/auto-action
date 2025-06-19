#!/bin/bash
set -e

echo "Installing Claude Code..."

# npm global bin을 PATH에 추가
export PATH=/home/coder/.npm-global/bin:$PATH

# npm global 디렉토리가 설정되었는지 확인
if [ ! -d "/home/coder/.npm-global" ]; then
    echo "⚠️  npm global directory not found. Please run setup-npm-global.sh first."
    exit 1
fi

# Claude Code 설치
npm install -g @anthropic-ai/claude-code

echo "✓ Claude Code installed successfully"
echo "  You can now use 'claude' command after reloading your shell or running:"
echo "  export PATH=/home/coder/.npm-global/bin:\$PATH"