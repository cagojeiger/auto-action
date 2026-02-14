# auto-action

GitOps 기반 자동화 인프라 배포 저장소입니다. GitHub Actions를 통해 Docker 이미지와 Helm 차트를 자동으로 빌드하고 배포합니다.

## 주요 특징

- **완전 자동화**: 코드 변경 감지 시 이미지 빌드 및 차트 배포 자동 실행
- **멀티 플랫폼 지원**: linux/amd64, linux/arm64 이미지 동시 빌드
- **의존성 자동 업데이트**: upstream 최신 버전 자동 추적 및 PR 생성
- **동적 매트릭스 빌드**: 변경된 아티팩트만 선택적으로 병렬 처리
- **빌드 실패 Slack 알림**: 모든 워크플로우 실패 시 Slack 자동 알림

## 디렉터리 구조

```
containers/           # Docker 이미지 소스
├── code-server/      # 웹 기반 VS Code + K8s/DevOps 도구
├── file-fetcher/     # rclone 기반 경량 파일 전송 init container
└── openclaw/         # OpenClaw AI Gateway

helm-charts/          # Helm 차트
├── code-server/      # code-server 배포용 차트
├── openclaw-stack/   # OpenClaw + Browserless 통합 차트
└── quick-deploy/     # 범용 빠른 배포 차트

docs/                 # 문서
└── ci-cd.md          # CI/CD 파이프라인 상세 가이드
```

## 빠른 시작

### Helm 차트

```bash
helm repo add auto-action https://cagojeiger.github.io/auto-action
helm repo update
helm search repo auto-action --versions
helm install my-release auto-action/openclaw-stack
```

### Docker 이미지

```bash
# OpenClaw Gateway
docker run -d -p 18789:18789 \
  -e OPENCLAW_GATEWAY_TOKEN=my-token \
  cagojeiger/openclaw:latest

# Code-Server (K8s 도구 포함)
docker run -d -p 8080:8080 -e PASSWORD=mypassword \
  cagojeiger/code-server:latest
```

## CI/CD 워크플로우

| 워크플로우 | 트리거 | 동작 |
|-----------|--------|------|
| Docker Image Push | `containers/**` 변경 | Docker Hub에 멀티 아키텍처 이미지 빌드/푸시 |
| Publish Helm Charts | `helm-charts/**` 변경 | GitHub Pages에 차트 패키징/배포 |
| Update Code-Server | 일일 | code-server 최신 버전 감지 → PR 생성 |
| Update File-Fetcher | 일일 | rclone 최신 버전 감지 → PR 생성 |
| Update OpenClaw | 일일 | OpenClaw npm 최신 버전 감지 → PR 생성 |
| Slack Notifications | 워크플로우 실패 시 | Slack 채널에 실패 알림 전송 |

상세 정보는 [docs/ci-cd.md](docs/ci-cd.md)를 참고하세요.

## 기여 방법

코드 변경 시 Google Style Guide를 따르고, 커밋 메시지는 Conventional Commits 규칙에 맞춰 작성합니다.

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
