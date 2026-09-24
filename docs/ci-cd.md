# CI/CD 파이프라인

## 개요

이 리포는 컨테이너 이미지와 Helm 차트를 함께 관리하고, 둘 다 GitHub Container Registry(GHCR)에 발행합니다.

| 산출물 | 소스 | 발행 위치 |
|--------|------|----------|
| 컨테이너 이미지 | `containers/{name}/` | `ghcr.io/cagojeiger/{name}:{version}` |
| Helm 차트 (OCI) | `helm-charts/{chart}/` | `oci://ghcr.io/cagojeiger/charts/{chart}` |

인증은 워크플로우의 `GITHUB_TOKEN`(`packages: write`)으로 하므로 별도 레지스트리 시크릿이 필요 없습니다.

## 워크플로우

| 파일 | 이름 | 트리거 | 하는 일 |
|------|------|--------|--------|
| `docker-push.yaml` | Docker Image Push | `containers/**` push, 수동 | 변경된 컨테이너를 amd64/arm64 로 빌드해 GHCR 에 push |
| `publish-helm-charts.yaml` | Publish Helm Charts | `helm-charts/**` push, 수동 | 변경된 차트를 패키징해 GHCR 에 OCI 로 push |
| `update-code-server.yaml` | Update Code-Server | 매일 00:15 UTC, 수동 | upstream code-server 새 버전 반영 → PR 병합 → 이미지 빌드 → 차트 발행 |
| `slack-notifications.yaml` | Slack Notifications | 위 워크플로우 완료 | 실패(`failure`)면 Slack 으로 알림 |

> GitHub 의 schedule 은 부하에 따라 늦게 시작합니다. 이 리포에서는 00:15 UTC 예약이 보통 04:40~05:00 UTC 에 실행됩니다.

---

## 흐름 1: 사람이 변경해서 main 에 병합

```
PR 병합 (main push)
 ├─ containers/** 변경 → Docker Image Push   → ghcr.io/cagojeiger/{name}
 └─ helm-charts/** 변경 → Publish Helm Charts → oci://ghcr.io/cagojeiger/charts/{chart}
```

- 두 워크플로우는 **서로 기다리지 않고 동시에** 돕니다. 이미지와 차트를 한 PR 에서 같이 바꾸면, 이미지 빌드가 끝나기 전에 차트가 먼저 발행될 수 있습니다.
- 변경 감지는 `git diff --name-only <before> <sha>` 로 합니다. 디렉토리를 지운 커밋도 변경으로 잡히므로, **지금 `Dockerfile` / `Chart.yaml` 이 남아 있는 것만** 빌드/발행합니다.

## 흐름 2: code-server 자동 업데이트

`update-code-server.yaml` → composite action `.github/actions/create-merge-trigger`

```
1. GitHub Releases 에서 coder/code-server 최신 버전 조회
2. Docker Hub 에 upstream 이미지(codercom/code-server:{ver})가 있는지 확인
3. upstream 차트(ci/helm-chart)를 helm-charts/code-server 로 rsync
   - appVersion = {ver}, version = {upstream 차트 버전}+{ver}
   - image.repository = ghcr.io/cagojeiger/code-server, image.tag = {ver}
4. containers/code-server/Dockerfile 의 ARG CODE_SERVER_VERSION 갱신
5. 변경이 있으면: 브랜치 push → PR 생성 → 병합 대기
6. Docker Image Push 를 dispatch 하고 끝날 때까지 대기   ← 실패하면 여기서 멈춤
7. Publish Helm Charts 를 dispatch
```

알아둘 점:

- **봇 병합은 push 트리거를 일으키지 않습니다.** `GITHUB_TOKEN` 으로 만든 push 는 다른 워크플로우를 트리거하지 않기 때문에, 6·7 단계에서 직접 dispatch 합니다.
- **이미지가 있어야 차트를 발행합니다.** 차트의 `image.tag` 가 없는 이미지를 가리키면 배포하는 쪽에서 `ErrImagePull` 이 나므로, 6 단계가 실패하면 7 단계는 실행되지 않습니다.
- **correlation_id**: `gh workflow run` 은 run id 를 돌려주지 않습니다. 그래서 고유값을 입력으로 넘기고, 실행 제목(`Docker Image Push [<id>]`)으로 자기 실행을 찾아 기다립니다.
- **실패하면 다음 날 자동으로 다시 하지 않습니다.** 5 단계에서 main 에 이미 병합됐기 때문에, 다음 실행은 "변경 없음"으로 끝납니다. 실패 알림을 받으면 원인을 고친 뒤 [수동 실행](#수동-실행)으로 이미지 → 차트 순서로 다시 발행하세요.

---

## 컨테이너 이미지

### 디렉토리 구조

```
containers/
└── {name}/
    ├── Dockerfile      # 필수
    ├── *.sh            # 선택 (이미지에 넣을 스크립트)
    └── README.md       # 선택
```

### 이미지 이름과 태그

```
containers/{name}/  →  ghcr.io/cagojeiger/{name}:{version}
                       ghcr.io/cagojeiger/{name}:latest
```

이미지에는 `org.opencontainers.image.source` 라벨이 붙어 GHCR 패키지가 이 리포에 연결됩니다.

### 버전 결정 규칙 (3단계 폴백)

1. **Helm 차트 appVersion**: `helm-charts/{name}/Chart.yaml` 이 있으면 `appVersion`
2. **Dockerfile ARG**: 첫 번째 `ARG *_VERSION=x.y.z` 의 값

   | Dockerfile | 추출 버전 |
   |------------|----------|
   | `ARG CODE_SERVER_VERSION=4.138.0` | ✅ 4.138.0 |
   | `ARG MY_TOOL_VERSION=2.3.4` | ✅ 2.3.4 |
   | `ARG VERSION=1.0.0` | ❌ 인식 안 됨 (`_VERSION` 패턴 필요) |
   | `ARG CODE_SERVER_VERSION=v4.138.0` | ⚠️ `v` 를 빼고 `4.138.0` |

3. **날짜**: `date +%Y.%m.%d` (예: `2026.09.24`)

### 빌드 설정

- 플랫폼: `linux/amd64`, `linux/arm64`
- 컨텍스트: `./containers/{name}/`

### 새 이미지 추가

1. `containers/my-app/Dockerfile` 작성 (`ARG MY_APP_VERSION=1.0.0` 처럼 버전 ARG 를 첫 ARG 로)
2. PR 병합 → 자동 빌드
3. 처음 발행된 패키지는 비공개일 수 있습니다. GitHub → Packages → `my-app` → Package settings 에서 Public 으로 바꿉니다.

---

## Helm 차트

### 설치

```bash
# 최신 버전
helm install my-release oci://ghcr.io/cagojeiger/charts/quick-deploy -f values.yaml

# 버전 지정 (build metadata 가 있는 버전도 그대로 적으면 된다)
helm install code-server oci://ghcr.io/cagojeiger/charts/code-server --version 3.53.0+4.138.0

# 차트 정보 확인
helm show chart oci://ghcr.io/cagojeiger/charts/code-server
```

OCI 레지스트리는 `helm repo add` / `helm search repo` 를 쓰지 않습니다. 버전 목록은 GitHub → Packages → `charts/{chart}` 에서 확인합니다.

ArgoCD 에서는 `repoURL: ghcr.io/cagojeiger/charts`, `chart: {chart}` 로 지정합니다 (Helm OCI 소스).

### 버전 규칙

- 차트 내용을 바꾸면 **`Chart.yaml` 의 `version` 을 올려야 합니다.** 같은 버전으로 다시 발행하면 GHCR 의 같은 태그를 덮어써서, 이미 받아간 쪽과 내용이 달라집니다.
- OCI 태그에는 `+` 를 쓸 수 없어 `3.53.0+4.138.0` 은 `3.53.0_4.138.0` 태그로 올라갑니다. `--version` 에는 `+` 로 적으면 helm 이 바꿔서 찾습니다.

---

## 수동 실행

```bash
# 특정 이미지 빌드 / 전체 빌드
gh workflow run docker-push.yaml -f container_name=code-server
gh workflow run docker-push.yaml

# 특정 차트 발행 / 전체 발행
gh workflow run publish-helm-charts.yaml -f chart_name=code-server
gh workflow run publish-helm-charts.yaml

# code-server 업데이트 즉시 실행
gh workflow run update-code-server.yaml
```

## 필요한 설정

| 항목 | 용도 |
|------|------|
| `GITHUB_TOKEN` (자동) | GHCR push, PR 생성/병합, 워크플로우 dispatch |
| `SLACK_WEBHOOK_URL` 시크릿 | 실패 알림 |
| Settings → General → Allow auto-merge | 자동 업데이트 PR 병합 |

## 이전 발행 위치 (더 이상 갱신하지 않음)

| 위치 | 마지막 발행 |
|------|-----------|
| Docker Hub `cagojeiger/code-server` | 이미지 `4.138.0` (2026-09-24) |
| GitHub Pages `https://cagojeiger.github.io/auto-action` | 차트 `code-server 3.53.0+4.138.0` (2026-09-24) |
