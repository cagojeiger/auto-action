#!/bin/bash
set -e

# pipx는 사용자별 PATH 설정이 필요
pipx ensurepath --force

echo "✓ pipx PATH configured"