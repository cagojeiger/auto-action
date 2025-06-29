#!/bin/bash
set -e

# npm은 사용자별 prefix 설정이 필요
npm config set prefix '/home/coder/.npm-global'

# .bashrc가 없으면 생성
if [ ! -f ~/.bashrc ]; then
    touch ~/.bashrc
fi

# npm global bin을 PATH에 추가
if ! grep -q "/home/coder/.npm-global/bin" ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# npm global bin path' >> ~/.bashrc
    echo 'export PATH="/home/coder/.npm-global/bin:${PATH}"' >> ~/.bashrc
fi

# .bashrc 소싱
source ~/.bashrc

echo "✓ npm global directory configured and PATH updated"