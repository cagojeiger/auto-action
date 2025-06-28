#!/bin/bash
set -e

echo "Setting up pipx for user..."

# pipx 환경 변수 설정
export PIPX_HOME="/home/coder/.local/pipx"
export PIPX_BIN_DIR="/home/coder/.local/bin"

# 디렉토리 생성
mkdir -p "$PIPX_HOME"
mkdir -p "$PIPX_BIN_DIR"

# pipx ensurepath 실행 (PATH 자동 설정)
python3 -m pipx ensurepath

# 환경 변수를 bashrc와 profile에 추가 (중복 체크)
for file in /home/coder/.bashrc /home/coder/.profile; do
    # PIPX_HOME 환경 변수 추가
    if ! grep -q "PIPX_HOME=" "$file" 2>/dev/null; then
        echo "export PIPX_HOME=\"$PIPX_HOME\"" >> "$file"
    fi
    
    # PIPX_BIN_DIR 환경 변수 추가
    if ! grep -q "PIPX_BIN_DIR=" "$file" 2>/dev/null; then
        echo "export PIPX_BIN_DIR=\"$PIPX_BIN_DIR\"" >> "$file"
    fi
    
    # PATH에 .local/bin 추가 (pipx ensurepath가 하지만 확실히 하기 위해)
    if ! grep -q "/.local/bin" "$file" 2>/dev/null; then
        echo 'export PATH="/home/coder/.local/bin:$PATH"' >> "$file"
    fi
done

echo "✓ pipx configured for user"
echo ""
echo "To install Python applications with pipx, use:"
echo "  pipx install <package-name>"
echo ""
echo "Examples:"
echo "  pipx install poetry"
echo "  pipx install black"
echo "  pipx install ruff"
echo "  pipx install pytest"
echo ""
echo "Installed applications will be available in: $PIPX_BIN_DIR"