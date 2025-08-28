# code-server with Kubernetes Tools

웹 브라우저에서 사용할 수 있는 VS Code(code-server)와 Kubernetes 도구들을 포함한 Docker 이미지입니다.

## 포함된 도구
- code-server (브라우저 기반 VS Code)
- **VS Code Extensions (Offline Support)**:
  - Continue AI code assistant (pre-downloaded VSIX)
- Kubernetes: kubectl, helm, k9s
- GitOps: ArgoCD CLI
- 개발 도구: Node.js LTS, Python 3.11, pipx, jq, yq, gh (GitHub CLI)
- 컨테이너 도구: skopeo, mc (MinIO Client)

## 빠른 시작

```bash
# Docker Hub에서 이미지 받기
docker pull cagojeiger/code-server:latest

# 로컬에서 실행
docker run -d -p 8080:8080 -e PASSWORD=mypassword cagojeiger/code-server:latest

# http://localhost:8080 에서 접속
```

## Kubernetes에서 사용

Helm 차트로 설치:
```bash
helm install code-server oci://registry-1.docker.io/cagojeiger/code-server \
  --set persistence.enabled=true \
  --set password="mypassword"
```

## 환경 설정

이미지에는 다음 환경 변수가 사전 설정되어 있습니다:
- `PATH`: pipx와 npm global 경로 포함
- `NPM_CONFIG_PREFIX`: `/home/coder/.npm-global`
- `PIPX_HOME`: `/home/coder/.local/pipx`
- `PIPX_BIN_DIR`: `/home/coder/.local/bin`

## 유용한 스크립트

이미지에는 다음 스크립트들이 `/tmp/`에 포함되어 있습니다:
- `gen_kube_config.sh` - Service Account를 사용한 kubeconfig 생성
- `setup-npm-global.sh` - npm 전역 패키지 prefix 설정 (최초 1회 필요)
- `setup-python-pipx.sh` - pipx PATH 설정 (최초 1회 필요)
- `install-claude-code.sh` - Claude Code CLI 설치

**VS Code Extensions (오프라인 지원):**
- `/home/coder/offline-extensions/install-continue.sh` - Continue AI extension 설치

사용 예시:
```bash
# npm global 설정 (최초 1회)
/tmp/setup-npm-global.sh

# pipx PATH 설정 (최초 1회)
/tmp/setup-python-pipx.sh

# Claude Code CLI 설치
/tmp/install-claude-code.sh

# Continue AI extension 설치 (오프라인)
/home/coder/offline-extensions/install-continue.sh

# 이후 pipx로 Python 도구 설치
pipx install poetry
pipx install black
pipx install ruff
```

## 지원 아키텍처
- linux/amd64
- linux/arm64