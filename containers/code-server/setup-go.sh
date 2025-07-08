#!/bin/bash
set -e

# .bashrc가 없으면 생성
if [ ! -f ~/.bashrc ]; then
    touch ~/.bashrc
fi

# Go 환경 변수 설정
export GOPATH="/home/coder/go"
export GOBIN="${GOPATH}/bin"

# 디렉토리 생성
mkdir -p "${GOPATH}/src" "${GOPATH}/bin" "${GOPATH}/pkg"

# Go 환경 변수를 .bashrc에 추가
if ! grep -q "GOPATH" ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# Go environment' >> ~/.bashrc
    echo 'export GOPATH="/home/coder/go"' >> ~/.bashrc
    echo 'export GOBIN="${GOPATH}/bin"' >> ~/.bashrc
    echo 'export PATH="/usr/local/go/bin:${GOBIN}:${PATH}"' >> ~/.bashrc
fi

# Go module 지원 활성화
if ! grep -q "GO111MODULE" ~/.bashrc; then
    echo 'export GO111MODULE=on' >> ~/.bashrc
fi

# .bashrc 소싱
source ~/.bashrc

echo "✓ Go environment configured"
echo "  GOPATH: ${GOPATH}"
echo "  GOBIN: ${GOBIN}"
echo "  Go modules enabled"