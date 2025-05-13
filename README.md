# auto-action

Kubernetes 환경에서 Code-Server를 쉽게 배포하고 관리하기 위한 도구입니다.

## 개발 환경 설정

VS Code의 Remote-Containers 확장을 사용하여 표준화된 개발 환경을 구성할 수 있습니다:

1. VS Code에서 Remote-Containers 확장을 설치합니다.
2. 이 리포지토리를 열고 Remote-Containers에서 개발을 시작합니다.

## 품질 관리 도구

이 리포지토리는 다음 린트 도구를 포함하고 있습니다:

- YAML 린트: GitHub Actions 워크플로우와 Helm 차트 파일 검증용
- Helm 린트: Helm 차트 구조적 문제 검사
- Dockerfile 린트: Dockerfile 모범 사례 준수 여부 검사
- Shell 스크립트 린트: 쉘 스크립트 검사

## pre-commit 훅 설정

pre-commit 훅을 설치하려면 다음 명령어를 실행하세요:

```bash
./.github/scripts/install-pre-commit.sh
```
