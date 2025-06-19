#!/bin/bash
set -e

echo "Setting up npm global directory..."

# npm global 디렉토리 설정
mkdir -p /home/coder/.npm-global
npm config set prefix '/home/coder/.npm-global'

# PATH 설정을 bashrc와 profile에 추가 (중복 체크)
if ! grep -q "/.npm-global/bin" /home/coder/.bashrc 2>/dev/null; then
    echo 'export PATH=/home/coder/.npm-global/bin:$PATH' >> /home/coder/.bashrc
fi

if ! grep -q "/.npm-global/bin" /home/coder/.profile 2>/dev/null; then
    echo 'export PATH=/home/coder/.npm-global/bin:$PATH' >> /home/coder/.profile
fi

echo "✓ npm global directory configured"