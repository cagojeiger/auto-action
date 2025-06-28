#!/bin/bash
set -e

echo "Setting up pipx for user..."

# 사용자 홈 디렉토리 기반 경로 설정 (하드코딩 제거)
USER_HOME="${HOME:-/home/coder}"
PIPX_HOME="$USER_HOME/.local/pipx"
PIPX_BIN_DIR="$USER_HOME/.local/bin"

echo "  - User home: $USER_HOME"
echo "  - pipx home: $PIPX_HOME"
echo "  - pipx bin: $PIPX_BIN_DIR"

# pipx 환경 변수 설정
export PIPX_HOME="$PIPX_HOME"
export PIPX_BIN_DIR="$PIPX_BIN_DIR"

# 디렉토리 생성
echo "Creating pipx directories..."
mkdir -p "$PIPX_HOME"
mkdir -p "$PIPX_BIN_DIR"

# pipx ensurepath 실행 (PATH 자동 설정)
echo "Running pipx ensurepath..."
python3 -m pipx ensurepath

# 쉘 설정 파일들에 환경 변수 추가
SHELL_FILES=("$USER_HOME/.bashrc" "$USER_HOME/.profile")

for file in "${SHELL_FILES[@]}"; do
    echo "Configuring shell file: $file"
    
    # 파일이 존재하지 않으면 생성
    if [[ ! -f "$file" ]]; then
        echo "Creating new shell configuration file: $file"
        touch "$file"
    fi
    
    # PIPX_HOME 환경 변수 추가 (중복 체크)
    if ! grep -q "^export PIPX_HOME=" "$file" 2>/dev/null; then
        echo "  Adding PIPX_HOME to $file"
        echo "export PIPX_HOME=\"$PIPX_HOME\"" >> "$file"
    else
        echo "  PIPX_HOME already configured in $file"
    fi
    
    # PIPX_BIN_DIR 환경 변수 추가 (중복 체크)
    if ! grep -q "^export PIPX_BIN_DIR=" "$file" 2>/dev/null; then
        echo "  Adding PIPX_BIN_DIR to $file"
        echo "export PIPX_BIN_DIR=\"$PIPX_BIN_DIR\"" >> "$file"
    else
        echo "  PIPX_BIN_DIR already configured in $file"
    fi
    
    # pipx ensurepath가 PATH를 설정하지만, 컨테이너 환경에서 확실히 하기 위해 추가
    if ! grep -q "\.local/bin" "$file" 2>/dev/null; then
        echo "  Adding .local/bin to PATH in $file"
        echo "export PATH=\"$PIPX_BIN_DIR:\$PATH\"" >> "$file"
    else
        echo "  .local/bin already in PATH in $file"
    fi
done

# pipx 설정 검증
echo ""
echo "Verifying pipx installation..."
if command -v pipx >/dev/null 2>&1; then
    echo "✓ pipx is available"
    pipx --version
else
    echo "⚠ pipx not found in current PATH"
fi

echo ""
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
echo ""
echo "Note: You may need to restart your shell or run 'source ~/.bashrc' to use the new PATH."