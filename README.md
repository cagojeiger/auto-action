# auto-action

소규모로 쓰는 컨테이너 이미지와 Helm 차트를 한 리포에서 관리합니다. GitHub Actions 가 빌드해서 GitHub Container Registry(GHCR)에 발행합니다.

## 관리 대상

| 종류 | 이름 | 발행 위치 | 설명 |
|------|------|----------|------|
| 이미지 | code-server | `ghcr.io/cagojeiger/code-server` | 웹 VS Code + K8s/DevOps 도구 |
| 차트 | code-server | `oci://ghcr.io/cagojeiger/charts/code-server` | upstream code-server 차트 + 위 이미지 |
| 차트 | quick-deploy | `oci://ghcr.io/cagojeiger/charts/quick-deploy` | 여러 앱을 values 하나로 배포하는 범용 차트 |

## 디렉터리 구조

```
containers/           # 컨테이너 이미지 소스
└── code-server/

helm-charts/          # Helm 차트
├── code-server/      # upstream 에서 동기화 (update-code-server 가 관리)
└── quick-deploy/

docs/
└── ci-cd.md          # CI/CD 파이프라인 상세
```

## 빠른 시작

### Helm 차트

```bash
helm install my-release oci://ghcr.io/cagojeiger/charts/quick-deploy -f values.yaml

helm install code-server oci://ghcr.io/cagojeiger/charts/code-server \
  --set persistence.enabled=true
```

### 컨테이너 이미지

```bash
docker run -d -p 8080:8080 -e PASSWORD=mypassword \
  ghcr.io/cagojeiger/code-server:latest
```

## CI/CD

| 워크플로우 | 트리거 | 동작 |
|-----------|--------|------|
| Docker Image Push | `containers/**` 변경, 수동 | 멀티 아키텍처(amd64/arm64) 이미지 빌드 → GHCR |
| Publish Helm Charts | `helm-charts/**` 변경, 수동 | 차트 패키징 → GHCR (OCI) |
| Update Code-Server | 매일 | 새 code-server 버전 반영 → PR 자동 병합 → 이미지 빌드 → (성공 시) 차트 발행 |
| Slack Notifications | 위 워크플로우 실패 | Slack 알림 |

흐름과 규칙(버전 결정, 변경 감지, 수동 실행, 실패 시 복구)은 [docs/ci-cd.md](docs/ci-cd.md)를 참고하세요.

## 기여 방법

코드 변경 시 Google Style Guide를 따르고, 커밋 메시지는 Conventional Commits 규칙에 맞춰 작성합니다.

## 라이선스

MIT 라이선스. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
