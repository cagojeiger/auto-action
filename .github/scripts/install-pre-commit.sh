set -euo pipefail

if ! command -v pre-commit &> /dev/null; then
  echo "pre-commit이 설치되어 있지 않습니다. 설치합니다..."
  pip install pre-commit
fi

pre-commit install

echo "pre-commit 훅이 성공적으로 설치되었습니다!"
