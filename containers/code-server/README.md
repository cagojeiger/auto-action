# code-server with DevOps Tools

웹 브라우저에서 사용할 수 있는 VS Code(code-server)와 DevOps/클라우드 도구들을 포함한 Docker 이미지입니다.

## 포함된 도구

- **에디터**: code-server (브라우저 기반 VS Code)
- **AI 코딩**: Claude Code, OpenCode (컨테이너 시작 시 자동 설치)
- **쉘**: Oh My Zsh + Powerlevel10k + zsh-autosuggestions + zsh-syntax-highlighting
- **Kubernetes**: kubectl, helm, k9s
- **GitOps**: ArgoCD CLI
- **IaC**: Terraform
- **시크릿**: Vault CLI, SOPS
- **클라우드**: AWS CLI v2
- **컨테이너**: Docker CLI, Docker Compose, skopeo, mc (MinIO Client)
- **런타임**: Node.js LTS, Python 3, Go
- **개발 도구**: jq, yq, gh (GitHub CLI), ripgrep (rg), pipx, fzf, tig, make, tree, pre-commit, direnv, bash-completion

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
- `PATH`: Go, pipx, npm global 경로 포함
- `NPM_CONFIG_PREFIX`: `/home/coder/.npm-global`
- `PIPX_HOME`: `/home/coder/.local/pipx`
- `PIPX_BIN_DIR`: `/home/coder/.local/bin`

## 스크립트 및 설정 파일

### 자동 실행 (entrypoint.d)

컨테이너 시작 시 `/etc/entrypoint.d/`의 스크립트가 자동 실행됩니다:
- `10-setup-zsh.sh` — Oh My Zsh + Powerlevel10k 초기 설정
- `20-setup-vscode-settings.sh` — VS Code 기본 설정 적용
- `30-setup-ai-tools.sh` — Claude Code, OpenCode 자동 설치 (첫 부팅 시)

### 수동 실행

- `/tmp/gen_kube_config.sh` — Service Account를 사용한 kubeconfig 생성

사용 예시:
```bash
# pipx로 Python 도구 설치
pipx install poetry
pipx install ruff
```

## 지원 아키텍처
- linux/amd64
- linux/arm64