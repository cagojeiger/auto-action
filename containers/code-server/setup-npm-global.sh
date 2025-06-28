#!/bin/bash
set -e

# npm은 사용자별 prefix 설정이 필요
npm config set prefix '/home/coder/.npm-global'

echo "✓ npm global directory configured"