# code-server with Kubernetes Tools

웹 브라우저에서 사용할 수 있는 VS Code(code-server)와 Kubernetes 도구들을 포함한 Docker 이미지입니다.

## 포함된 도구
- code-server (브라우저 기반 VS Code)
- Kubernetes: kubectl, helm, k9s
- 개발 도구: Node.js LTS, jq, yq, gomplate, gh (GitHub CLI)
- 기타: skopeo, mc (MinIO Client)

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

## 유용한 스크립트

이미지에는 다음 스크립트들이 `/tmp/`에 포함되어 있습니다:
- `gen_kube_config.sh` - Service Account를 사용한 kubeconfig 생성
- `setup-npm-global.sh` - npm 전역 패키지 설정
- `install-claude-code.sh` - Claude Code CLI 설치

사용 예시:
```bash
# 컨테이너 내에서 실행
/tmp/setup-npm-global.sh
/tmp/install-claude-code.sh
```

## 지원 아키텍처
- linux/amd64
- linux/arm64